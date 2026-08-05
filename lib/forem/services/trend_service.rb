module Forem
  module Services
    # Service for interacting with the Forem Trends API.
    #
    # Trends are algorithmically-derived, "hot and recent" topic clusters made
    # up of related articles. Access via {Client#trends}. All methods inject
    # the client's requestor automatically so no additional configuration is
    # required. Trends are read-only via the public API.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   trends = client.trends.list
    #   trend  = client.trends.retrieve("ai-agents")
    #   articles = client.trends.articles("ai-agents")
    #
    # @see Trend
    # @see https://developers.forem.com/api/v1
    class TrendService < BaseService
      # List hot and recent trends.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (default: 10)
      # @param opts [Hash] per-request options
      # @return [Forem::ListObject<Trend>] paginated list of trends
      #
      # @example
      #   client.trends.list(per_page: 20)
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        Trend.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single trend by its numeric ID or slug.
      #
      # @param id_or_slug [Integer, String] the trend's ID or slug
      # @param opts [Hash] per-request options
      # @return [Trend] the trend matching the given ID or slug
      #
      # @example
      #   client.trends.retrieve("ai-agents")
      #   client.trends.retrieve(3)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id_or_slug, opts = {})
        Trend.retrieve(id_or_slug, opts_with_requestor(opts))
      end

      # List the articles belonging to a trend.
      #
      # @param id_or_slug [Integer, String] the trend's ID or slug
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (default: 10)
      # @option params [String] :sort +"score"+ to sort purely by article score;
      #   omit for the default ordering (trend membership distance, then score)
      # @param opts [Hash] per-request options
      # @return [Array<Forem::Article>] articles associated with the trend
      #
      # @example
      #   client.trends.articles("ai-agents", per_page: 5, sort: "score")
      #
      # @see https://developers.forem.com/api/v1
      def articles(id_or_slug, params = {}, opts = {})
        Trend.articles(id_or_slug, params, opts_with_requestor(opts))
      end
    end
  end
end
