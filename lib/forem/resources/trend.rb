module Forem
  # Represents a trend detected across a Forem instance's content.
  #
  # Trends are algorithmically-derived topic clusters ("hot and recent"
  # subject areas) made up of related articles. They are read-only via the
  # public API — there is no create/update/delete surface, only listing,
  # retrieval, and a nested endpoint for the articles that make up a trend.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/trends
  #   - +Retrieve+ — GET /api/trends/:id_or_slug
  #
  # == Trend Fields
  #
  # - +id+ (Integer)
  # - +name+ (String)
  # - +slug+ (String)
  # - +description+ (String)
  # - +key_questions+ (Array<String>) — Questions the trend's content clusters around
  # - +score+ (Float) — Relative trend strength/ranking score
  # - +articles_count+ (Integer) — Number of articles associated with the trend
  # - +cover_image+ (String) — URL of the trend's cover image
  # - +first_observed_at+ (String) — ISO 8601 timestamp
  # - +last_observed_at+ (String) — ISO 8601 timestamp
  # - +created_at+ (String) — ISO 8601 timestamp
  # - +updated_at+ (String) — ISO 8601 timestamp
  # - +type_of+ (String) — Always +"trend"+
  #
  # The +show+ response additionally includes +top_articles+, an array of up
  # to three of the trend's highest-scoring published articles, each with
  # +id+, +title+, +slug+, +score+, and +published_at+.
  #
  # @example List hot and recent trends
  #   trends = client.trends.list(per_page: 10)
  #   trends.data.each { |t| puts "#{t.name} (#{t.score})" }
  #
  # @example Retrieve a trend by ID or slug
  #   trend = client.trends.retrieve("ai-agents")
  #   puts trend.description
  #   trend.top_articles.each { |a| puts a["title"] }
  #
  # @example List the articles that make up a trend
  #   articles = client.trends.articles("ai-agents", per_page: 20, sort: "score")
  #   articles.each { |a| puts a.title }
  #
  # @see https://developers.forem.com/api/v1
  class Trend < APIResource
    extend APIOperations::List
    extend APIOperations::Retrieve

    OBJECT_NAME = "trend"
    RESOURCE_PATH = "/api/trends"

    # Return the articles belonging to a trend.
    #
    # Sends a GET request to +/api/trends/:id_or_slug/articles+. Unlike
    # {.list} and {.retrieve}, this is a class method that takes the trend's
    # ID or slug directly, so it can be called without first retrieving the
    # trend itself.
    #
    # @param id_or_slug [Integer, String] the trend's numeric ID or slug
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 10)
    # @option params [String] :sort +"score"+ to sort purely by article score;
    #   omit for the default ordering (trend membership distance, then score)
    # @param opts [Hash] per-request options
    # @option opts [String] :api_key override the API key for this request.
    # @option opts [APIRequestor] :requestor a custom requestor to use.
    # @return [Array<Forem::Article>] articles associated with the trend
    # @example
    #   Forem::Trend.articles("ai-agents", per_page: 5, requestor: requestor)
    # @see https://developers.forem.com/api/v1
    def self.articles(id_or_slug, params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "#{resource_path}/#{id_or_slug}/articles", params, opts)
      (resp.parsed_body || []).map { |item| Forem::Article.construct_from(item, requestor: requestor) }
    end
  end
end
