module Forem
  module APIOperations
    # Adds a +list+ class method to any resource that extends this module.
    #
    # Fetches a paginated collection from the resource's path and wraps the
    # result in a {ListObject} that supports manual and automatic pagination.
    #
    # @example Extending a resource class
    #   class Forem::Article < Forem::APIResource
    #     extend APIOperations::List
    #   end
    module List
      # Retrieve a paginated list of resources from the Forem API.
      #
      # Sends a +GET+ request to {APIResource.resource_path} with +params+
      # appended as query-string parameters. The response array is converted
      # into an array of resource instances and wrapped in a {ListObject} that
      # exposes pagination helpers.
      #
      # Pagination defaults: +page+ 1, +per_page+ 30 (matching Forem API
      # defaults). These can be overridden via +params+.
      #
      # @param params [Hash] query parameters for filtering and pagination.
      # @option params [Integer] :page the page number to fetch (default +1+).
      # @option params [Integer] :per_page the number of items per page
      #   (default +30+, maximum varies by endpoint).
      # @option params [String] :tag filter articles by tag (articles endpoint).
      # @option params [String] :username filter by username.
      # @option params [String] :state filter by state (e.g. +"fresh"+,
      #   +"rising"+, +"all"+).
      # @param opts [Hash] per-request options.
      # @option opts [String] :api_key override the API key for this request.
      # @option opts [APIRequestor] :requestor a custom requestor to use and
      #   to forward to subsequent page fetches.
      # @return [ListObject] a paginated list object wrapping the current
      #   page's resources.
      # @raise [AuthenticationError] on HTTP 401.
      # @raise [AuthorizationError] on HTTP 403.
      # @raise [ForemError] on other API or network errors.
      #
      # @example Fetching the first page of articles
      #   articles = client.articles.list(per_page: 10)
      #   articles.map(&:title)
      #   #=> ["Article 1", "Article 2", ...]
      #
      # @example Filtering articles by tag
      #   client.articles.list(tag: "ruby", per_page: 5).each do |a|
      #     puts a.title
      #   end
      #
      # @see https://developers.forem.com/api/v1#tag/articles/operation/getArticles
      def list(params = {}, opts = {})
        requestor = opts[:requestor]
        resp = request(:get, resource_path, params, opts)
        data = (resp.parsed_body || []).map { |item| construct_from(item, requestor: requestor) }
        per_page = params[:per_page] || params["per_page"] || 30
        page = params[:page] || params["page"] || 1

        ListObject.new(
          data: data,
          current_page: page.to_i,
          per_page: per_page.to_i,
          resource_class: self,
          filters: params.reject { |k, _| [:page, :per_page, "page", "per_page"].include?(k) },
          requestor: requestor
        )
      end
    end
  end
end
