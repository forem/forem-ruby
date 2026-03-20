module Forem
  module Services
    class RecommendedArticlesListService < BaseService
      def list(params = {}, opts = {})
        RecommendedArticlesList.list(params, opts_with_requestor(opts))
      end

      def create(params = {}, opts = {})
        RecommendedArticlesList.create(params, opts_with_requestor(opts))
      end

      def retrieve(id, opts = {})
        RecommendedArticlesList.retrieve(id, opts_with_requestor(opts))
      end

      def update(id, params = {}, opts = {})
        RecommendedArticlesList.update(id, params, opts_with_requestor(opts))
      end
    end
  end
end
