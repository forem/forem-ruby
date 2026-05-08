module Forem
  module APIOperations
    # Adds +delete+ as both a class method and an instance method to any
    # resource that includes this module.
    #
    # The class method deletes by ID; the instance method deletes the receiver
    # using its own {APIResource#resource_url}. Both methods return a resource
    # object if the server responds with a body, otherwise they return +nil+
    # (class method) or +self+ (instance method).
    #
    # The +self.included+ hook extends the including class with {ClassMethods}
    # so the class-level +delete+ is available alongside the instance method.
    #
    # @example Extending a resource class
    #   class Forem::Article < Forem::APIResource
    #     include APIOperations::Delete
    #   end
    module Delete
      # Hook called when {Delete} is included in a class.
      #
      # Extends the including class with {ClassMethods}.
      #
      # @param base [Class] the class including this module.
      # @return [void]
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Class-level delete helpers.
      module ClassMethods
        # Delete a resource by its ID via the Forem API.
        #
        # Sends a +DELETE+ request to <tt>{resource_path}/{id}</tt>. If the
        # server responds with a non-empty body it is used to construct a
        # resource instance (representing the deleted object); otherwise
        # +nil+ is returned.
        #
        # @param id [Integer, String] the unique identifier of the resource to
        #   delete.
        # @param opts [Hash] per-request options.
        # @option opts [String] :api_key override the API key for this request.
        # @option opts [APIRequestor] :requestor a custom requestor to use.
        # @return [ForemObject, nil] the deleted resource (if the API returns
        #   a body), or +nil+.
        # @raise [NotFoundError] on HTTP 404.
        # @raise [AuthenticationError] on HTTP 401.
        # @raise [AuthorizationError] on HTTP 403.
        # @raise [ForemError] on other API or network errors.
        #
        # @example Deleting an article by ID
        #   client.articles.delete(12345)
        #
        # @see https://developers.forem.com/api/v1
        def delete(id, opts = {})
          requestor = opts[:requestor]
          resp = request(:delete, "#{resource_path}/#{id}", {}, opts)
          resp.parsed_body ? construct_from(resp.parsed_body, requestor: requestor) : nil
        end
      end

      # Delete this resource instance via the Forem API.
      #
      # Sends a +DELETE+ request to this instance's {APIResource#resource_url}.
      # If the server responds with a non-empty body it is used to construct
      # a new resource instance (representing the deleted state); otherwise
      # +self+ is returned.
      #
      # @param opts [Hash] per-request options.
      # @option opts [String] :api_key override the API key for this request.
      # @option opts [APIRequestor] :requestor a custom requestor to use.
      # @return [ForemObject] a new resource instance built from the response
      #   body, or +self+ if the response has no body.
      # @raise [InvalidRequestError] if the instance has no +id+.
      # @raise [NotFoundError] on HTTP 404.
      # @raise [AuthenticationError] on HTTP 401.
      # @raise [AuthorizationError] on HTTP 403.
      # @raise [ForemError] on other API or network errors.
      #
      # @example Deleting the current instance
      #   article.delete
      def delete(opts = {})
        requestor = opts[:requestor] || @requestor
        resp = request(:delete, resource_url, {}, opts)
        resp.parsed_body ? self.class.construct_from(resp.parsed_body, requestor: requestor) : self
      end
    end
  end
end
