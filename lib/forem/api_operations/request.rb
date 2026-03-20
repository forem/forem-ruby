module Forem
  module APIOperations
    # Provides +request+ as both a class method and an instance method on any
    # class that includes this module.
    #
    # Including {Request} is the only prerequisite for a class to issue
    # authenticated HTTP requests. It is included in {APIResource} and
    # therefore inherited by every concrete resource class.
    #
    # The module uses a +self.included+ hook to also extend the including class
    # with {ClassMethods}, making the class-level +request+ available for
    # module methods such as {APIOperations::Create#create} and
    # {APIOperations::List#list}.
    #
    # The +:requestor+ key in +opts+ is consumed here and never forwarded to
    # {APIRequestor#request}, allowing callers to substitute a custom
    # requestor without the underlying HTTP layer seeing the option.
    module Request
      # Hook called when {Request} is included in a class.
      #
      # Extends the including class with {ClassMethods} so that class-level
      # resource operations (create, list, retrieve, etc.) can call
      # +self.request+.
      #
      # @param base [Class] the class including this module.
      # @return [void]
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Class-level request helpers mixed into every class that includes
      # {Request}.
      module ClassMethods
        # Issue an authenticated HTTP request using the configured requestor.
        #
        # Looks for a +:requestor+ key in +opts+ and uses it in preference to
        # {Forem.default_requestor}, then removes the key before forwarding
        # +opts+ to {APIRequestor#request}.
        #
        # @param method [Symbol] the HTTP verb (+:get+, +:post+, +:put+,
        #   +:delete+).
        # @param path [String] the API path (e.g. +"/api/articles"+).
        # @param params [Hash] query parameters or JSON body payload.
        # @param opts [Hash] per-request options.
        # @option opts [APIRequestor] :requestor a custom requestor to use
        #   instead of the global default.
        # @option opts [String] :api_key override the API key for this request.
        # @option opts [String] :api_base override the base URL for this request.
        # @return [ForemResponse] the response wrapper.
        # @raise [ForemError] on any API or network error.
        #
        # @example
        #   Forem::Article.request(:get, "/api/articles", { per_page: 5 })
        def request(method, path, params = {}, opts = {})
          requestor = opts.delete(:requestor) || Forem.default_requestor
          requestor.request(method, path, params, opts)
        end
      end

      # Issue an authenticated HTTP request on behalf of this resource
      # instance.
      #
      # Delegates to the class-level {ClassMethods#request} method so the
      # same requestor-selection logic applies.
      #
      # @param method [Symbol] the HTTP verb.
      # @param path [String] the API path.
      # @param params [Hash] query parameters or JSON body payload.
      # @param opts [Hash] per-request options (see {ClassMethods#request}).
      # @return [ForemResponse] the response wrapper.
      # @raise [ForemError] on any API or network error.
      #
      # @example Refreshing an instance manually
      #   article.request(:get, article.resource_url)
      def request(method, path, params = {}, opts = {})
        self.class.request(method, path, params, opts)
      end
    end
  end
end
