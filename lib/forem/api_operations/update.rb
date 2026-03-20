module Forem
  module APIOperations
    # Adds an +update+ class method to any resource that extends this module.
    #
    # Sends a PUT request to a specific resource URL with the supplied
    # parameters as a JSON body, and returns a new resource instance
    # constructed from the API response.
    #
    # @example Extending a resource class
    #   class Forem::Article < Forem::APIResource
    #     extend APIOperations::Update
    #   end
    module Update
      # Update an existing resource via the Forem API.
      #
      # Sends a +PUT+ request to <tt>{resource_path}/{id}</tt> with +params+
      # serialised as a JSON body, and returns a new resource instance
      # reflecting the updated state as returned by the server.
      #
      # @param id [Integer, String] the unique identifier of the resource to
      #   update.
      # @param params [Hash] the attributes to update (e.g.
      #   <tt>{ article: { title: "New title" } }</tt>).
      # @param opts [Hash] per-request options.
      # @option opts [String] :api_key override the API key for this request.
      # @option opts [APIRequestor] :requestor a custom requestor to use.
      # @return [ForemObject] a resource instance populated with the updated
      #   data returned by the API.
      # @raise [NotFoundError] on HTTP 404 (resource does not exist).
      # @raise [InvalidRequestError] on HTTP 422 (validation errors).
      # @raise [AuthenticationError] on HTTP 401.
      # @raise [AuthorizationError] on HTTP 403.
      # @raise [ForemError] on other API or network errors.
      #
      # @example Updating an article's title
      #   article = Forem::Article.update(12345, article: { title: "Updated title" })
      #   article.title  #=> "Updated title"
      #
      # @see https://developers.forem.com/api/v1#tag/articles/operation/updateArticle
      def update(id, params = {}, opts = {})
        resp = request(:put, "#{resource_path}/#{id}", params, opts)
        construct_from(resp.parsed_body)
      end
    end
  end
end
