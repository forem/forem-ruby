module Forem
  module Services
    # Service for interacting with the Forem Concepts API.
    #
    # Concepts are semantic, ML-generated categories: articles are classified
    # under a concept when their embedding is close enough to the concept's
    # anchor embedding. This service covers the public concept endpoints
    # (+/api/concepts+); creating and deleting concepts is an admin-only
    # operation exposed by {AdminConceptService}.
    #
    # Access via {Client#concepts}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   concepts = client.concepts.list(days: 30)
    #   concept  = client.concepts.retrieve(concepts.first.id)
    #   concept.daily_metrics.first.articles_count
    #
    # @see Concept
    # @see https://developers.forem.com/api/v1
    class ConceptService < BaseService
      # List the concepts accessible to the authenticated user.
      #
      # Super admins see every concept; other users see only the concepts
      # they have been granted access to. Each concept includes nested
      # +daily_metrics+ covering the last +days+ days, newest first.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      #   (default: 50, max: 100)
      # @option params [Integer] :days number of days of activity to include
      #   in +daily_metrics+ (default: 7, minimum: 1)
      # @param opts [Hash] per-request options
      # @return [Forem::ListObject<Concept>] paginated list of concepts
      #
      # @example
      #   client.concepts.list(per_page: 20, days: 30)
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        Concept.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single concept by its numeric ID.
      #
      # The response includes nested +daily_metrics+ for the last +days+ days
      # and a +top_articles+ array with the concept's three highest-scoring
      # articles.
      #
      # @param id [Integer, String] the concept ID
      # @param params [Hash] query parameters
      # @option params [Integer] :days number of days of activity to include
      #   in +daily_metrics+ (default: 7, minimum: 1)
      # @param opts [Hash] per-request options
      # @return [Concept] the concept with the given ID
      #
      # @example
      #   concept = client.concepts.retrieve(7)
      #   concept.daily_metrics.map(&:popularity_score)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, params = {}, opts = {})
        Concept.retrieve(id, params, opts_with_requestor(opts))
      end

      # Update an existing concept.
      #
      # Params are wrapped in the +concept+ key expected by the API, so they
      # can be passed flat. Only +score+, +description+, and
      # +similarity_threshold+ are permitted. Updating the description
      # regenerates the concept's anchor embedding; updating the description
      # or the similarity threshold re-classifies existing articles in the
      # background.
      #
      # @param id [Integer, String] the concept ID to update
      # @param params [Hash] concept attributes to change
      # @option params [Float] :score new curation score
      # @option params [String] :description new semantic description used to
      #   regenerate the anchor embedding
      # @option params [Float] :similarity_threshold new cosine distance
      #   threshold (0.0–1.0)
      # @param opts [Hash] per-request options
      # @return [Concept] the updated concept
      #
      # @example
      #   client.concepts.update(7, description: "Storage engines", score: 4.5)
      #
      # @see https://developers.forem.com/api/v1
      def update(id, params = {}, opts = {})
        Concept.update(id, params, opts_with_requestor(opts))
      end

      # List the published articles classified under a concept.
      #
      # Articles are ordered by semantic distance (closest first) with the
      # article score as a tiebreaker, unless +sort+ is +"score"+.
      #
      # @param id [Integer, String] the concept ID
      # @param params [Hash] query parameters
      # @option params [String] :sort +"score"+ to sort by article score;
      #   otherwise sorted by semantic distance
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      #   (default: 10)
      # @param opts [Hash] per-request options
      # @return [Forem::ListObject<Forem::Article>] paginated list of articles
      #
      # @example
      #   client.concepts.articles(7, sort: "score", per_page: 25)
      #
      # @see https://developers.forem.com/api/v1
      def articles(id, params = {}, opts = {})
        Concept.articles(id, params, opts_with_requestor(opts))
      end

      # Semantically search the concepts accessible to the caller.
      #
      # The query is embedded and compared against each concept's anchor
      # embedding. Results come back closest-first, each with +distance+ and
      # +similarity+ alongside the usual concept fields. This endpoint
      # requires an API key and is not paginated.
      #
      # @param params [Hash] query parameters
      # @option params [String] :q (required) the search text
      # @option params [Integer] :per_page number of concepts to return
      #   (default: 10, max: 50)
      # @option params [Float] :threshold optional maximum cosine distance
      #   (0.0–2.0) for a concept to be included
      # @param opts [Hash] per-request options
      # @return [Array<Concept>] matching concepts, closest first
      #
      # @example
      #   client.concepts.search(q: "vector databases", per_page: 5)
      #
      # @see https://developers.forem.com/api/v1
      def search(params = {}, opts = {})
        Concept.search(params, opts_with_requestor(opts))
      end
    end
  end
end
