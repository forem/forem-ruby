module Forem
  module APIOperations
    # Adds a +save+ instance method to any resource that includes this module.
    #
    # +save+ is the instance-level complement to the class-level
    # {APIOperations::Update#update}. It persists the current resource to the
    # API by issuing a PUT request to the instance's own
    # {APIResource#resource_url}, and returns a new resource object reflecting
    # the server's response.
    #
    # @example Including in a resource class
    #   class Forem::Article < Forem::APIResource
    #     include APIOperations::Save
    #   end
    module Save
      # Save (update) this resource instance via the Forem API.
      #
      # Sends a +PUT+ request to {APIResource#resource_url} with +params+
      # serialised as a JSON body. The server response is used to construct
      # and return a new resource instance representing the updated state.
      #
      # Unlike {APIResource#refresh}, which reloads in-place, +save+ returns
      # a *new* instance and does not mutate the receiver.
      #
      # @param params [Hash] the attributes to update (e.g.
      #   <tt>{ article: { title: "New title" } }</tt>). Defaults to +{}+.
      # @param opts [Hash] per-request keyword options.
      # @option opts [String] :api_key override the API key for this request.
      # @option opts [APIRequestor] :requestor a custom requestor to use.
      # @return [ForemObject] a new resource instance populated with the
      #   updated data returned by the API.
      # @raise [InvalidRequestError] if this instance has no +id+ (via
      #   {APIResource#resource_url}).
      # @raise [NotFoundError] on HTTP 404.
      # @raise [InvalidRequestError] on HTTP 422 (validation errors).
      # @raise [AuthenticationError] on HTTP 401.
      # @raise [AuthorizationError] on HTTP 403.
      # @raise [ForemError] on other API or network errors.
      #
      # @example Updating a fetched article
      #   article = Forem::Article.retrieve(12345)
      #   updated = article.save(article: { title: "Brand new title" })
      #   updated.title  #=> "Brand new title"
      #
      # @see https://developers.forem.com/api/v1#tag/articles/operation/updateArticle
      def save(params = {}, **opts)
        resp = request(:put, resource_url, params, opts)
        self.class.construct_from(resp.parsed_body)
      end
    end
  end
end
