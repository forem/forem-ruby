module Forem
  module APIOperations
    # Adds a +retrieve+ class method to any resource that extends this module.
    #
    # Fetches a single resource by its ID with a GET request and returns a
    # resource instance populated from the API response.
    #
    # @example Extending a resource class
    #   class Forem::Article < Forem::APIResource
    #     extend APIOperations::Retrieve
    #   end
    module Retrieve
      # Retrieve a single resource by its ID from the Forem API.
      #
      # Sends a +GET+ request to <tt>{resource_path}/{id}</tt> and constructs
      # a resource instance from the response body.
      #
      # @param id [Integer, String] the unique identifier of the resource to
      #   fetch.
      # @param opts [Hash] per-request options.
      # @option opts [String] :api_key override the API key for this request.
      # @option opts [APIRequestor] :requestor a custom requestor to use.
      # @return [ForemObject] the resource instance populated with data from
      #   the API response.
      # @raise [NotFoundError] on HTTP 404 (resource does not exist).
      # @raise [AuthenticationError] on HTTP 401.
      # @raise [AuthorizationError] on HTTP 403.
      # @raise [ForemError] on other API or network errors.
      #
      # @example Fetching an article by ID
      #   article = client.articles.retrieve(12345)
      #   article.title   #=> "Hello, world!"
      #   article.id      #=> 12345
      #
      # @see https://developers.forem.com/api/v1#tag/articles/operation/getArticleById
      def retrieve(id, opts = {})
        requestor = opts[:requestor]
        resp = request(:get, "#{resource_path}/#{id}", {}, opts)
        construct_from(resp.parsed_body, requestor: requestor)
      end
    end
  end
end
