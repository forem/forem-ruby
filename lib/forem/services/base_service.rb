module Forem
  module Services
    # Abstract base class for all Forem API service objects.
    #
    # Each service wraps a specific area of the Forem API and delegates method
    # calls to the corresponding model class, automatically injecting the
    # client's {APIRequestor} so that the correct credentials and base URL are
    # used for every request.
    #
    # Concrete subclasses (e.g. {ArticleService}, {UserService}) are accessed
    # through the reader methods on {Client} and should not be instantiated
    # directly.
    #
    # @abstract Subclass and add public methods that delegate to the
    #   appropriate model class.
    #
    # @see Client
    # @see https://developers.forem.com/api/v1
    class BaseService
      # Create a new service instance bound to the given requestor.
      #
      # @param requestor [APIRequestor] the HTTP requestor that carries the
      #   client's configuration (API key, base URL, etc.)
      # @return [BaseService] a new service instance
      def initialize(requestor)
        @requestor = requestor
      end

      private

      # Merge the client's requestor into a per-request options hash.
      #
      # All service methods call this helper before forwarding opts to model
      # class methods so that the model uses this client's requestor rather
      # than the global one.
      #
      # @param opts [Hash] per-request options supplied by the caller
      # @return [Hash] opts with the +:requestor+ key set to this service's
      #   {APIRequestor}
      def opts_with_requestor(opts)
        opts.merge(requestor: @requestor)
      end

      # Wrap flat attributes in the envelope key an endpoint expects.
      #
      # Some write endpoints expect a nested body
      # (<tt>{ badge: { title: "..." } }</tt>). This lets service methods take
      # flat attributes and nest them on the caller's behalf. Params that are
      # already enveloped are passed through untouched, so both call styles
      # work.
      #
      # @param key [Symbol] the envelope key (e.g. +:badge+)
      # @param params [Hash] attributes, flat or already enveloped
      # @return [Hash] the enveloped params
      #
      # @example
      #   enveloped(:badge, title: "Top 7")   #=> { badge: { title: "Top 7" } }
      def enveloped(key, params)
        return params if params.key?(key) || params.key?(key.to_s)

        { key => params }
      end
    end
  end
end
