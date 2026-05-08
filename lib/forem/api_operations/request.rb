module Forem
  module APIOperations
    # Provides +request+ as both a class method and an instance method on any
    # class that includes this module.
    #
    # Including {Request} is the only prerequisite for a class to issue
    # authenticated HTTP requests. It is included in {APIResource} and
    # therefore inherited by every concrete resource class.
    #
    # The module uses a +self.included+ hook to also extend the including
    # class with {ClassMethods}, making the class-level +request+ available
    # for module methods such as {APIOperations::Create#create} and
    # {APIOperations::List#list}.
    #
    # The +:requestor+ key in +opts+ is consumed here and never forwarded to
    # {APIRequestor#request}.
    module Request
      # Hook called when {Request} is included in a class.
      #
      # @param base [Class] the class including this module.
      # @return [void]
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Class-level request helpers mixed into every class that includes
      # {Request}.
      module ClassMethods
        # Issue an authenticated HTTP request using the supplied requestor.
        #
        # The +:requestor+ key in +opts+ is required — there is no global
        # default. In normal use this is supplied automatically by a
        # {Forem::Client} via its service objects.
        #
        # @param method [Symbol] the HTTP verb (+:get+, +:post+, +:put+,
        #   +:delete+).
        # @param path [String] the API path (e.g. +"/api/articles"+).
        # @param params [Hash] query parameters or JSON body payload.
        # @param opts [Hash] per-request options.
        # @option opts [APIRequestor] :requestor (required) the requestor
        #   that issues this call. Normally injected by a {Forem::Client}.
        # @option opts [String] :api_key override the API key for this request.
        # @option opts [String] :api_base override the base URL for this request.
        # @return [ForemResponse] the response wrapper.
        # @raise [ArgumentError] if no +:requestor+ is supplied.
        # @raise [ForemError] on any API or network error.
        def request(method, path, params = {}, opts = {})
          requestor = opts.delete(:requestor)
          unless requestor
            raise ArgumentError,
                  "Forem requires an explicit requestor — call this method " \
                  "through a Forem::Client (e.g. client.articles.list)."
          end
          requestor.request(method, path, params, opts)
        end
      end

      # Issue an authenticated HTTP request on behalf of this resource
      # instance.
      #
      # Falls back to the requestor stored on the instance (set when the
      # object was constructed by a service call) if no explicit
      # +:requestor+ is supplied in +opts+. Delegates to the class-level
      # {ClassMethods#request} for the actual transport.
      #
      # @param method [Symbol] the HTTP verb.
      # @param path [String] the API path.
      # @param params [Hash] query parameters or JSON body payload.
      # @param opts [Hash] per-request options.
      # @option opts [APIRequestor] :requestor override the instance's
      #   stored requestor for this call.
      # @return [ForemResponse] the response wrapper.
      # @raise [ArgumentError] if neither the instance nor +opts+ supply a
      #   requestor.
      # @raise [ForemError] on any API or network error.
      def request(method, path, params = {}, opts = {})
        opts = opts.dup
        opts[:requestor] ||= @requestor if instance_variable_defined?(:@requestor)
        self.class.request(method, path, params, opts)
      end
    end
  end
end
