module Forem
  module Services
    # Service for interacting with the Forem Articles API.
    #
    # Access via {Client#articles}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   service = client.articles
    #   service.list(per_page: 5, tag: "ruby")
    #
    # @see Article
    # @see https://developers.forem.com/api/v1#/operations/getArticles
    class ArticleService < BaseService
      # List published articles.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @option params [String] :tag filter by a single tag name
      # @option params [String] :tags comma-separated list of tags to include
      # @option params [String] :tags_exclude comma-separated list of tags to exclude
      # @option params [String] :username filter by author username
      # @option params [String] :state article state ("fresh", "rising", "all")
      # @option params [Integer] :top number of days back to look for top articles
      # @option params [String] :collection_id filter by collection ID
      # @param opts [Hash] per-request options
      # @return [Array<Article>] list of published articles
      #
      # @example
      #   client.articles.list(tag: "ruby", per_page: 10)
      #
      # @see https://developers.forem.com/api/v1#/operations/getArticles
      def list(params = {}, opts = {})
        Article.list(params, opts_with_requestor(opts))
      end

      # Create a new article.
      #
      # @param params [Hash] article attributes
      # @option params [String] :title article title
      # @option params [String] :body_markdown article body in Markdown
      # @option params [Boolean] :published whether to publish immediately
      # @option params [Array<String>] :tags list of tag names
      # @option params [String] :series name of a series to add the article to
      # @option params [String] :canonical_url canonical URL override
      # @option params [String] :description article description / excerpt
      # @param opts [Hash] per-request options
      # @return [Article] the newly created article
      #
      # @example
      #   client.articles.create(
      #     title: "Hello World",
      #     body_markdown: "# Hello\nThis is my first post.",
      #     published: true,
      #     tags: ["ruby", "beginners"]
      #   )
      #
      # @see https://developers.forem.com/api/v1#/operations/createArticle
      def create(params = {}, opts = {})
        Article.create(params, opts_with_requestor(opts))
      end

      # Retrieve a single article by its numeric ID.
      #
      # @param id [Integer, String] the article ID
      # @param opts [Hash] per-request options
      # @return [Article] the article with the given ID
      #
      # @example
      #   client.articles.retrieve(12345)
      #
      # @see https://developers.forem.com/api/v1#/operations/getArticleById
      def retrieve(id, opts = {})
        Article.retrieve(id, opts_with_requestor(opts))
      end

      # Update an existing article.
      #
      # @param id [Integer, String] the article ID to update
      # @param params [Hash] article attributes to change
      # @option params [String] :title new title
      # @option params [String] :body_markdown new body in Markdown
      # @option params [Boolean] :published publish or unpublish the article
      # @option params [Array<String>] :tags updated list of tag names
      # @param opts [Hash] per-request options
      # @return [Article] the updated article
      #
      # @example
      #   client.articles.update(12345, title: "Updated Title", published: true)
      #
      # @see https://developers.forem.com/api/v1#/operations/updateArticle
      def update(id, params = {}, opts = {})
        Article.update(id, params, opts_with_requestor(opts))
      end

      # List articles authored by the authenticated user.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @param opts [Hash] per-request options
      # @return [Array<Article>] articles belonging to the current user
      #
      # @example
      #   client.articles.me(per_page: 30)
      #
      # @see https://developers.forem.com/api/v1#/operations/getUserArticles
      def me(params = {}, opts = {})
        Article.me(params, opts_with_requestor(opts))
      end

      # List published articles authored by the authenticated user.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @param opts [Hash] per-request options
      # @return [Array<Article>] published articles belonging to the current user
      #
      # @example
      #   client.articles.me_published
      #
      # @see https://developers.forem.com/api/v1#/operations/getUserArticles
      def me_published(params = {}, opts = {})
        Article.me_published(params, opts_with_requestor(opts))
      end

      # List unpublished articles (drafts) authored by the authenticated user.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @param opts [Hash] per-request options
      # @return [Array<Article>] unpublished articles belonging to the current user
      #
      # @example
      #   client.articles.me_unpublished
      #
      # @see https://developers.forem.com/api/v1#/operations/getUserArticles
      def me_unpublished(params = {}, opts = {})
        Article.me_unpublished(params, opts_with_requestor(opts))
      end

      # List all articles (published and unpublished) authored by the authenticated user.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @param opts [Hash] per-request options
      # @return [Array<Article>] all articles belonging to the current user
      #
      # @example
      #   client.articles.me_all
      #
      # @see https://developers.forem.com/api/v1#/operations/getUserArticles
      def me_all(params = {}, opts = {})
        Article.me_all(params, opts_with_requestor(opts))
      end

      # List the most recently published articles.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @param opts [Hash] per-request options
      # @return [Array<Article>] latest published articles in chronological order
      #
      # @example
      #   client.articles.latest(per_page: 20)
      #
      # @see https://developers.forem.com/api/v1#/operations/getLatestArticles
      def latest(params = {}, opts = {})
        Article.latest(params, opts_with_requestor(opts))
      end

      # Search articles by keyword.
      #
      # @param params [Hash] query parameters
      # @option params [String] :q the search term
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Array<Article>] articles matching the search query
      #
      # @example
      #   client.articles.search(q: "ruby on rails")
      #
      # @see https://developers.forem.com/api/v1#/operations/searchArticles
      def search(params = {}, opts = {})
        Article.search(params, opts_with_requestor(opts))
      end

      # Retrieve an article by its author username and slug.
      #
      # @param username [String] the author's username
      # @param slug [String] the article slug
      # @param opts [Hash] per-request options
      # @return [Article] the matching article
      #
      # @example
      #   client.articles.retrieve_by_path("jsmith", "my-great-post")
      #
      # @see https://developers.forem.com/api/v1#/operations/getArticleByPath
      def retrieve_by_path(username, slug, opts = {})
        Article.retrieve_by_path(username, slug, opts_with_requestor(opts))
      end
    end
  end
end
