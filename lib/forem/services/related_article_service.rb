module Forem
  module Services
    # Service for interacting with the Forem Related Articles API.
    #
    # Access via {Client#related_articles}.
    #
    # @see RelatedArticle
    # @see https://developers.forem.com/api/v1
    class RelatedArticleService < BaseService
      # Discover related articles for an organization.
      #
      # @param params [Hash] query parameters (must include +:organization_id+)
      # @param opts [Hash] per-request options
      # @return [ListObject<RelatedArticle>] list of related articles
      def list(params = {}, opts = {})
        RelatedArticle.list(params, opts_with_requestor(opts))
      end
    end
  end
end
