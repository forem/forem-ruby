module Forem
  module APIOperations
    # Adds a +create+ class method to any resource that extends this module.
    #
    # Sends a POST request to the resource's collection path with the supplied
    # parameters as a JSON body, and returns a new resource instance populated
    # from the API response.
    #
    # @example Extending a resource class
    #   class Forem::Article < Forem::APIResource
    #     extend APIOperations::Create
    #   end
    module Create
      # Create a new resource via the Forem API.
      #
      # Sends a +POST+ request to {APIResource.resource_path} with +params+
      # serialised as a JSON body. The server response is used to construct
      # and return a new resource instance.
      #
      # @param params [Hash] the attributes for the new resource (e.g.
      #   <tt>{ article: { title: "Hello", body_markdown: "..." } }</tt>).
      # @param opts [Hash] per-request options.
      # @option opts [String] :api_key override the API key for this request.
      # @option opts [APIRequestor] :requestor a custom requestor to use.
      # @return [ForemObject] the newly-created resource, constructed from the
      #   API response body.
      # @raise [InvalidRequestError] on HTTP 422 (validation errors).
      # @raise [AuthenticationError] on HTTP 401.
      # @raise [AuthorizationError] on HTTP 403.
      # @raise [ForemError] on other API or network errors.
      #
      # @example Creating an article
      #   article = client.articles.create(
      #     article: { title: "Hello, world!", body_markdown: "**hi**", published: true }
      #   )
      #   article.id     #=> 12345
      #   article.title  #=> "Hello, world!"
      #
      # @see https://developers.forem.com/api/v1#tag/articles/operation/createArticle
      def create(params = {}, opts = {})
        requestor = opts[:requestor]
        resp = request(:post, resource_path, params, opts)
        construct_from(resp.parsed_body, requestor: requestor)
      end
    end
  end
end
