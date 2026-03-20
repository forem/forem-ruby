require "cgi"

module Forem
  # Represents a Forem article (blog post).
  #
  # Articles are the core content type on Forem. They support full CRUD
  # operations plus several custom endpoints for filtering by auth state,
  # latest publication order, and full-text search.
  #
  # Available operations (via mixins):
  #   - +List+   — GET /api/articles
  #   - +Create+ — POST /api/articles
  #   - +Retrieve+ — GET /api/articles/:id
  #   - +Update+ — PUT /api/articles/:id
  #   - +Save+   — instance-level save (create or update)
  #
  # == List Parameters
  #
  # When calling +Article.list+, the following query parameters are supported:
  #
  # - +tag+ (String) — Filter by tag; can combine with +top+
  # - +tags+ (String) — Comma-separated tags; returns articles with ANY of these
  # - +tags_exclude+ (String) — Comma-separated tags to exclude
  # - +username+ (String) — Filter by user or organization username
  # - +state+ (String) — One of: +"fresh"+, +"rising"+, +"all"+.
  #   Note: +state=all+ only works combined with +username+ and returns up to 1000 items
  # - +top+ (Integer) — Most popular articles in the last N days; can combine with +tag+
  # - +collection_id+ (Integer) — Articles in a specific collection, ordered by publication date
  # - +page+ (Integer) — Page number (default: 1)
  # - +per_page+ (Integer) — Items per page (default: 30, max: 1000)
  #
  # == Create Parameters
  #
  # When calling +Article.create+, wrap all fields under the +:article+ key:
  #
  # @option params [Hash] :article the article payload
  # @option params [String] 'article.title' (required)
  # @option params [String] 'article.body_markdown' (required)
  # @option params [String] 'article.description' (required)
  # @option params [Boolean] 'article.published' (default: false)
  # @option params [String] 'article.tags' comma-separated tags
  # @option params [String] 'article.series' series name (nullable)
  # @option params [String] 'article.canonical_url' (nullable)
  # @option params [String] 'article.main_image' (nullable)
  # @option params [Integer] 'article.organization_id' (nullable)
  #
  # @example List published articles
  #   articles = Forem::Article.list(per_page: 10, tag: "ruby")
  #   articles.data.each { |a| puts a.title }
  #
  # @example Create a new article
  #   article = Forem::Article.create(
  #     article: { title: "Hello World", body_markdown: "# Hello", published: false }
  #   )
  #
  # @example Retrieve a single article by ID
  #   article = Forem::Article.retrieve(12345)
  #   puts article.title
  #
  # @see https://developers.forem.com/api/v1#/operations/getArticles
  # @see https://developers.forem.com/api/v1#/operations/createArticle
  # @see https://developers.forem.com/api/v1#/operations/updateArticle
  class Article < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Save

    OBJECT_NAME = "article"
    RESOURCE_PATH = "/api/articles"

    # Unpublish this article, reverting it to draft status.
    #
    # Marks the article as draft. Keeps content, deletes notifications,
    # preserves comments. Requires admin or moderator role.
    #
    # Sends a PUT request to +/api/articles/:id/unpublish+.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   article = Forem::Article.retrieve(42)
    #   article.unpublish
    # @see https://developers.forem.com/api/v1#/operations/unpublishArticle
    def unpublish(opts = {})
      request(:put, "#{resource_url}/unpublish", {}, opts)
    end

    # Return articles authored by the authenticated user (all statuses).
    #
    # Requires authentication. Returns articles in reverse chronological order,
    # 30 per page.
    #
    # Sends a GET request to +/api/articles/me+.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::Article>] list of the authenticated user's articles
    # @example
    #   my_articles = Forem::Article.me(per_page: 5)
    #   my_articles.each { |a| puts "#{a.id}: #{a.title}" }
    # @see https://developers.forem.com/api/v1#/operations/getUserArticles
    def self.me(params = {}, opts = {})
      resp = request(:get, "/api/articles/me", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    # Return published articles authored by the authenticated user.
    #
    # Requires authentication. Returns articles in reverse chronological order,
    # 30 per page.
    #
    # Sends a GET request to +/api/articles/me/published+.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::Article>] list of the authenticated user's published articles
    # @example
    #   published = Forem::Article.me_published(per_page: 20)
    #   published.each { |a| puts a.title }
    # @see https://developers.forem.com/api/v1#/operations/getUserArticles
    def self.me_published(params = {}, opts = {})
      resp = request(:get, "/api/articles/me/published", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    # Return unpublished (draft) articles authored by the authenticated user.
    #
    # Requires authentication. Returns articles in reverse chronological order,
    # 30 per page.
    #
    # Sends a GET request to +/api/articles/me/unpublished+.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::Article>] list of the authenticated user's unpublished articles
    # @example
    #   drafts = Forem::Article.me_unpublished
    #   drafts.each { |a| puts "Draft: #{a.title}" }
    # @see https://developers.forem.com/api/v1#/operations/getUserArticles
    def self.me_unpublished(params = {}, opts = {})
      resp = request(:get, "/api/articles/me/unpublished", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    # Return all articles authored by the authenticated user regardless of status.
    #
    # Requires authentication. Returns articles in reverse chronological order,
    # 30 per page.
    #
    # Sends a GET request to +/api/articles/me/all+.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::Article>] all articles (published + drafts) for the authenticated user
    # @example
    #   all = Forem::Article.me_all
    #   puts "Total articles: #{all.length}"
    # @see https://developers.forem.com/api/v1#/operations/getUserArticles
    def self.me_all(params = {}, opts = {})
      resp = request(:get, "/api/articles/me/all", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    # Return the most recently published articles ordered by publication date.
    #
    # Sends a GET request to +/api/articles/latest+.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::Article>] latest published articles
    # @example
    #   latest = Forem::Article.latest(per_page: 5)
    #   latest.each { |a| puts "#{a.published_at}: #{a.title}" }
    # @see https://developers.forem.com/api/v1#/operations/getLatestArticles
    def self.latest(params = {}, opts = {})
      resp = request(:get, "/api/articles/latest", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    # Search published articles by keyword.
    #
    # Sends a GET request to +/api/articles/search+.
    #
    # @param params [Hash] query parameters
    # @option params [String] :q search query string
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::Article>] articles matching the search query
    # @example
    #   results = Forem::Article.search(q: "ruby on rails")
    #   results.each { |a| puts a.title }
    # @see https://developers.forem.com/api/v1
    def self.search(params = {}, opts = {})
      resp = request(:get, "/api/articles/search", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    # Retrieve a single article by the author's username and the article's slug.
    #
    # Sends a GET request to +/api/articles/:username/:slug+.
    #
    # @param username [String] the author's Forem username
    # @param slug [String] the article slug (the URL-friendly title segment)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::Article] the matching article
    # @example
    #   article = Forem::Article.retrieve_by_path("ben", "my-first-post")
    #   puts article.title
    # @see https://developers.forem.com/api/v1#/operations/getArticleByPath
    def self.retrieve_by_path(username, slug, opts = {})
      resp = request(:get, "/api/articles/#{CGI.escape(username)}/#{CGI.escape(slug)}", {}, opts)
      construct_from(resp.parsed_body)
    end
  end
end
