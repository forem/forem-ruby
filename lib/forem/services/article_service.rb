module Forem
  module Services
    class ArticleService < BaseService
      def list(params = {}, opts = {})
        Article.list(params, opts_with_requestor(opts))
      end

      def create(params = {}, opts = {})
        Article.create(params, opts_with_requestor(opts))
      end

      def retrieve(id, opts = {})
        Article.retrieve(id, opts_with_requestor(opts))
      end

      def update(id, params = {}, opts = {})
        Article.update(id, params, opts_with_requestor(opts))
      end

      def me(params = {}, opts = {})
        Article.me(params, opts_with_requestor(opts))
      end

      def me_published(params = {}, opts = {})
        Article.me_published(params, opts_with_requestor(opts))
      end

      def me_unpublished(params = {}, opts = {})
        Article.me_unpublished(params, opts_with_requestor(opts))
      end

      def me_all(params = {}, opts = {})
        Article.me_all(params, opts_with_requestor(opts))
      end

      def latest(params = {}, opts = {})
        Article.latest(params, opts_with_requestor(opts))
      end

      def search(params = {}, opts = {})
        Article.search(params, opts_with_requestor(opts))
      end

      def retrieve_by_path(username, slug, opts = {})
        Article.retrieve_by_path(username, slug, opts_with_requestor(opts))
      end
    end
  end
end
