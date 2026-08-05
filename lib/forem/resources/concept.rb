module Forem
  # Represents a Forem concept (a semantic, ML-generated tag).
  #
  # Concepts are semantic categories derived from article embeddings rather
  # than from explicit user tags: each concept carries an anchor embedding
  # generated from its +description+, and articles whose embeddings fall
  # within the concept's +similarity_threshold+ are classified under it.
  # They are used for advanced semantic categorization, automated feeds, and
  # interest mapping.
  #
  # The public concepts endpoints are readable by any authenticated user (a
  # super admin sees every concept, other users see the concepts they have
  # been granted access to). Creating and deleting concepts is an admin-only
  # operation exposed separately under +/api/admin/concepts+.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/concepts
  #   - +Update+   — PUT /api/concepts/:id
  #
  # Custom class methods:
  #   - +retrieve+ — GET /api/concepts/:id
  #   - +articles+ — GET /api/concepts/:id/articles
  #   - +search+   — GET /api/concepts/search
  #
  # == Concept Fields
  #
  # - +id+ (Integer) — Unique concept ID
  # - +name+ (String) — Human readable label for the concept
  # - +slug+ (String) — URL-friendly identifier
  # - +description+ (String, nullable) — Semantic definition used to generate
  #   the concept's anchor embedding
  # - +parent_id+ (Integer, nullable) — Parent concept when using a hierarchy
  # - +score+ (Float) — Concept popularity / curation score
  # - +similarity_threshold+ (Float, nullable) — Cosine distance threshold
  #   (0.0–1.0) an article embedding must satisfy to be classified under the
  #   concept
  # - +created_at+ / +updated_at+ (String) — ISO 8601 timestamps
  # - +daily_metrics+ (Array) — Nested per-day activity rollups, newest first.
  #   Each entry has +date+, +articles_count+, +comments_count+,
  #   +page_views+, +reactions_count+, and +popularity_score+
  # - +top_articles+ (Array) — Only on +retrieve+ / +update+ responses; the
  #   three highest-scoring articles for the concept, each with +id+,
  #   +title+, +slug+, +score+, and +published_at+
  #
  # Results from {search} carry two extra fields: +distance+ (cosine distance
  # from the query embedding) and +similarity+ (+1.0 - distance+).
  #
  # @example List concepts with a 30-day metrics window
  #   concepts = client.concepts.list(per_page: 20, days: 30)
  #   concepts.each { |c| puts "#{c.id}: #{c.name} (#{c.score})" }
  #
  # @example Retrieve a concept and read its nested daily metrics
  #   concept = client.concepts.retrieve(7)
  #   concept.daily_metrics.each { |m| puts "#{m.date}: #{m.articles_count}" }
  #
  # @example Update a concept (params are wrapped in +concept:+ automatically)
  #   client.concepts.update(7, description: "Databases and storage engines")
  #
  # @example List the articles classified under a concept
  #   client.concepts.articles(7, sort: "score", per_page: 25).each do |a|
  #     puts a.title
  #   end
  #
  # @example Semantic search across accessible concepts
  #   client.concepts.search(q: "vector databases", per_page: 5).each do |c|
  #     puts "#{c.name}: #{c.similarity}"
  #   end
  #
  # @see https://developers.forem.com/api/v1
  class Concept < APIResource
    extend APIOperations::List
    extend APIOperations::Update

    OBJECT_NAME = "concept"
    RESOURCE_PATH = "/api/concepts"

    # Retrieve a single concept by its numeric ID.
    #
    # Sends a GET request to +/api/concepts/:id+. Unlike the standard
    # {APIOperations::Retrieve} mixin this accepts query params, because the
    # endpoint takes a +days+ window that controls how many nested
    # +daily_metrics+ entries are returned.
    #
    # @param id [Integer, String] the concept ID
    # @param params [Hash] query parameters
    # @option params [Integer] :days days of activity to include in
    #   +daily_metrics+ (default: 7, minimum: 1)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::Concept] the concept with the given ID
    # @example
    #   Forem::Concept.retrieve(7, { days: 30 }, requestor: requestor)
    # @see https://developers.forem.com/api/v1
    def self.retrieve(id, params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "#{resource_path}/#{id}", params, opts)
      construct_from(resp.parsed_body, requestor: requestor)
    end

    # Update an existing concept.
    #
    # Sends a PUT request to +/api/concepts/:id+. The Forem API expects the
    # attributes to be nested under a +concept+ key, so flat params are
    # wrapped automatically; already-wrapped params are passed through
    # untouched.
    #
    # Only +score+, +description+, and +similarity_threshold+ are permitted
    # by the API. Changing the description regenerates the concept's anchor
    # embedding, and changing either the description or the similarity
    # threshold enqueues a background re-classification of existing articles.
    #
    # @param id [Integer, String] the concept ID to update
    # @param params [Hash] concept attributes to change
    # @option params [Float] :score new curation score
    # @option params [String] :description new semantic description
    # @option params [Float] :similarity_threshold new cosine distance
    #   threshold (0.0–1.0)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::Concept] the updated concept
    # @example
    #   Forem::Concept.update(7, { similarity_threshold: 0.8 }, requestor: requestor)
    # @see https://developers.forem.com/api/v1
    def self.update(id, params = {}, opts = {})
      super(id, wrap_params(params), opts)
    end

    # Return the published articles classified under a concept.
    #
    # Sends a GET request to +/api/concepts/:id/articles+. Articles are
    # ordered by cosine similarity to the concept (closest first), with the
    # article score as a tiebreaker, unless +sort+ is +"score"+ in which case
    # they are ordered by article score alone.
    #
    # @param id [Integer, String] the concept ID
    # @param params [Hash] query parameters
    # @option params [String] :sort +"score"+ to sort by article score;
    #   omitted or any other value sorts by semantic distance
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page
    #   (default: 10)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ListObject<Forem::Article>] paginated list of articles
    #   belonging to the concept
    # @example
    #   articles = Forem::Concept.articles(7, { sort: "score" }, requestor: requestor)
    #   articles.each { |a| puts a.title }
    # @see https://developers.forem.com/api/v1
    def self.articles(id, params = {}, opts = {})
      Forem::Article.paginated_list("#{resource_path}/#{id}/articles", params, opts)
    end

    # Semantically search the concepts accessible to the caller.
    #
    # Sends a GET request to +/api/concepts/search+. The query text is
    # embedded and compared against each concept's anchor embedding; results
    # are returned closest-first and are not paginated (only the number of
    # results is configurable). Each returned concept carries +distance+ and
    # +similarity+ in addition to the usual concept fields.
    #
    # Requires an API key — unlike the other concept endpoints, this action
    # cannot be called with a session user.
    #
    # @param params [Hash] query parameters
    # @option params [String] :q (required) the search text
    # @option params [Integer] :per_page number of concepts to return
    #   (default: 10, max: 50)
    # @option params [Float] :threshold optional maximum cosine distance
    #   (0.0–2.0); concepts further away are filtered out
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::Concept>] matching concepts, closest first
    # @example
    #   results = Forem::Concept.search({ q: "databases" }, requestor: requestor)
    #   results.each { |c| puts "#{c.name} #{c.distance}" }
    # @see https://developers.forem.com/api/v1
    def self.search(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "#{resource_path}/search", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item, requestor: requestor) }
    end

    # Nest flat attributes under the +concept+ key expected by the API.
    #
    # @param params [Hash] the caller-supplied attributes
    # @return [Hash] params wrapped in a +concept+ key, or unchanged if they
    #   already are
    def self.wrap_params(params)
      return params if params.key?(:concept) || params.key?("concept")

      { concept: params }
    end
    private_class_method :wrap_params
  end
end
