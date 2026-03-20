module Forem
  module Services
    # Service for interacting with the Forem Recommended Articles Lists API.
    #
    # Recommended articles lists are curated collections of articles surfaced
    # to specific user segments.
    # Access via {Client#recommended_articles_lists}. All methods inject the
    # client's requestor automatically so no additional configuration is
    # required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   lists = client.recommended_articles_lists.list
    #   list  = client.recommended_articles_lists.retrieve(2)
    #
    # @see RecommendedArticlesList
    # @see https://developers.forem.com/api/v1
    class RecommendedArticlesListService < BaseService
      # List all recommended articles lists.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Array<RecommendedArticlesList>] all recommended articles lists
      #
      # @example
      #   client.recommended_articles_lists.list
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        RecommendedArticlesList.list(params, opts_with_requestor(opts))
      end

      # Create a new recommended articles list.
      #
      # @param params [Hash] list attributes
      # @option params [String] :name name of the list
      # @option params [Integer] :segment_id the audience segment this list
      #   targets
      # @param opts [Hash] per-request options
      # @return [RecommendedArticlesList] the newly created list
      #
      # @example
      #   client.recommended_articles_lists.create(
      #     name: "Top Ruby Articles",
      #     segment_id: 5
      #   )
      #
      # @see https://developers.forem.com/api/v1
      def create(params = {}, opts = {})
        RecommendedArticlesList.create(params, opts_with_requestor(opts))
      end

      # Retrieve a single recommended articles list by its numeric ID.
      #
      # @param id [Integer, String] the list ID
      # @param opts [Hash] per-request options
      # @return [RecommendedArticlesList] the list with the given ID
      #
      # @example
      #   client.recommended_articles_lists.retrieve(2)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, opts = {})
        RecommendedArticlesList.retrieve(id, opts_with_requestor(opts))
      end

      # Update an existing recommended articles list.
      #
      # @param id [Integer, String] the list ID to update
      # @param params [Hash] list attributes to change
      # @option params [String] :name new name for the list
      # @option params [Integer] :segment_id new target segment
      # @param opts [Hash] per-request options
      # @return [RecommendedArticlesList] the updated list
      #
      # @example
      #   client.recommended_articles_lists.update(2, name: "Best Ruby Content")
      #
      # @see https://developers.forem.com/api/v1
      def update(id, params = {}, opts = {})
        RecommendedArticlesList.update(id, params, opts_with_requestor(opts))
      end
    end
  end
end
