module Forem
  module Services
    # Service for interacting with the Forem Admin Concepts API.
    #
    # Provides full CRUD over concepts — the curated topics Forem uses to
    # classify articles and comments — plus the +trigger_lookback+ action that
    # re-runs classification over older content. Every endpoint requires an API
    # key with super admin privileges; regular user keys receive HTTP 401.
    #
    # Access via {Client#admin_concepts}. All methods inject the client's
    # requestor automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("admin-api-key")
    #   concept = client.admin_concepts.create(name: "Machine Learning")
    #   client.admin_concepts.trigger_lookback(concept.id, days: 90)
    #
    # @see AdminConcept
    # @see Forem::Concept
    # @see https://developers.forem.com/api/v1
    class AdminConceptService < BaseService
      # List concepts, ordered by name.
      #
      # Returns a trimmed projection of each concept: +id+, +name+, +slug+,
      # +description+, +parent_id+, +similarity_threshold+,
      # +max_lookback_days+, +created_at+, and +updated_at+.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page results per page (default: 50, max: 100)
      # @param opts [Hash] per-request options
      # @return [ListObject] the current page of {AdminConcept} records
      #
      # @example
      #   client.admin_concepts.list(per_page: 100)
      def list(params = {}, opts = {})
        AdminConcept.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single concept by ID.
      #
      # Returns the full concept record, unlike {#list} which returns a
      # trimmed projection.
      #
      # @param id [Integer, String] the concept ID
      # @param opts [Hash] per-request options
      # @return [AdminConcept] the requested concept
      # @raise [NotFoundError] if no concept has that ID
      #
      # @example
      #   client.admin_concepts.retrieve(7)
      def retrieve(id, opts = {})
        AdminConcept.retrieve(id, opts_with_requestor(opts))
      end

      # Create a new concept.
      #
      # Attributes are sent wrapped in a +concept+ object for you. The API
      # generates the slug, and generates a description and the anchor
      # embedding from +name+, so only +name+ is required.
      #
      # @param params [Hash] concept attributes
      # @option params [String] :name the concept name, max 100 chars (required)
      # @option params [String] :description human-readable description
      # @option params [Integer] :parent_id ID of the parent concept
      # @option params [Float] :similarity_threshold classification cutoff (0.0–1.0)
      # @option params [Float] :score ranking score for the concept
      # @param opts [Hash] per-request options
      # @return [AdminConcept] the newly created concept
      # @raise [InvalidRequestError] on HTTP 422 (validation errors)
      #
      # @example
      #   client.admin_concepts.create(
      #     name: "Machine Learning",
      #     description: "Posts about ML and AI",
      #     similarity_threshold: 0.8
      #   )
      def create(params = {}, opts = {})
        AdminConcept.create(params, opts_with_requestor(opts))
      end

      # Update an existing concept.
      #
      # Attributes are sent wrapped in a +concept+ object for you. Only
      # +name+, +description+, +parent_id+, +similarity_threshold+, and
      # +score+ are writable; +slug+ and +max_lookback_days+ are ignored.
      # Changing +name+ or +description+ regenerates the anchor embedding.
      #
      # @param id [Integer, String] the concept ID
      # @param params [Hash] attributes to change (see {#create})
      # @param opts [Hash] per-request options
      # @return [AdminConcept] the updated concept
      # @raise [NotFoundError] if no concept has that ID
      # @raise [InvalidRequestError] on HTTP 422 (validation errors)
      #
      # @example
      #   client.admin_concepts.update(7, similarity_threshold: 0.9)
      def update(id, params = {}, opts = {})
        AdminConcept.update(id, params, opts_with_requestor(opts))
      end

      # Delete a concept.
      #
      # The API responds with HTTP 204 and no body on success.
      #
      # @param id [Integer, String] the concept ID
      # @param opts [Hash] per-request options
      # @return [AdminConcept, nil] +nil+ for the usual empty response
      # @raise [NotFoundError] if no concept has that ID
      #
      # @example
      #   client.admin_concepts.delete(7)
      def delete(id, opts = {})
        AdminConcept.delete(id, opts_with_requestor(opts))
      end

      # Queue a classification lookback for a concept.
      #
      # Enqueues a background job that classifies records from the last
      # +days+ days. The value must be positive and strictly greater than the
      # concept's current +max_lookback_days+, otherwise the API responds with
      # HTTP 422.
      #
      # @param id [Integer, String] the concept ID
      # @param params [Hash] request body
      # @option params [Integer] :days how many days back to classify (required)
      # @param opts [Hash] per-request options
      # @return [ForemObject] an object carrying a +message+
      # @raise [InvalidRequestError] on HTTP 422 when +days+ is out of range
      #
      # @example
      #   client.admin_concepts.trigger_lookback(7, days: 90).message
      def trigger_lookback(id, params = {}, opts = {})
        AdminConcept.trigger_lookback(id, params, opts_with_requestor(opts))
      end
    end
  end
end
