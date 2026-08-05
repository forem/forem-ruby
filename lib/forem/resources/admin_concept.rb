module Forem
  # Represents a Concept managed through the admin-only Concepts API.
  #
  # Concepts are curated topics that Forem uses to classify articles and
  # comments via embedding similarity. The admin endpoints under
  # +/api/admin/concepts+ expose full CRUD over those records plus a
  # +trigger_lookback+ action that re-runs classification over older content.
  # Every endpoint requires an API key belonging to a super admin — a regular
  # user key receives HTTP 401.
  #
  # Read-only access to the public concept endpoints lives on
  # {Forem::Concept}; this resource is strictly the administrative surface.
  #
  # Available operations:
  #   - +List+             — GET /api/admin/concepts
  #   - +Retrieve+         — GET /api/admin/concepts/:id
  #   - +create+           — POST /api/admin/concepts
  #   - +update+           — PUT /api/admin/concepts/:id
  #   - +Delete+           — DELETE /api/admin/concepts/:id
  #   - +trigger_lookback+ — POST /api/admin/concepts/:id/trigger_lookback
  #
  # == Concept Fields
  #
  # - +id+ (Integer) — Unique identifier
  # - +name+ (String, required) — Display name, max 100 characters
  # - +slug+ (String) — Generated from +name+ by the API; not writable
  # - +description+ (String) — Generated from +name+ when omitted on create
  # - +parent_id+ (Integer) — Optional parent concept, forming a hierarchy
  # - +similarity_threshold+ (Float) — Cosine similarity cutoff between +0.0+
  #   and +1.0+ used when classifying records (may be +null+)
  # - +score+ (Float) — Ranking score for the concept
  # - +max_lookback_days+ (Integer) — How far back classification has already
  #   been run; read-only (set by +trigger_lookback+, never by create/update)
  # - +created_at+ / +updated_at+ (String) — ISO 8601 timestamps
  #
  # The list endpoint returns a trimmed projection (+id+, +name+, +slug+,
  # +description+, +parent_id+, +similarity_threshold+, +max_lookback_days+,
  # +created_at+, +updated_at+) ordered by +name+, while the show endpoint
  # returns the full record.
  #
  # == Writable attributes
  #
  # Only +name+, +description+, +parent_id+, +similarity_threshold+, and
  # +score+ are permitted on create and update. Any other attribute (notably
  # +slug+ and +max_lookback_days+) is silently ignored by the API. Attributes
  # are sent wrapped in a +concept+ object, which this resource does for you.
  #
  # @example List concepts
  #   concepts = client.admin_concepts.list(per_page: 100)
  #   concepts.each { |c| puts "#{c.id}: #{c.name}" }
  #
  # @example Create a concept (flat params — the +concept:+ wrapper is added)
  #   concept = client.admin_concepts.create(
  #     name: "Machine Learning",
  #     description: "Posts about ML and AI",
  #     similarity_threshold: 0.8
  #   )
  #
  # @see Forem::Concept
  # @see https://developers.forem.com/api/v1
  class AdminConcept < APIResource
    extend APIOperations::List
    extend APIOperations::Retrieve
    include APIOperations::Delete

    OBJECT_NAME = "admin_concept"
    RESOURCE_PATH = "/api/admin/concepts"

    # Create a new concept.
    #
    # Sends a +POST+ to +/api/admin/concepts+ with the attributes wrapped in a
    # +concept+ object. The API generates the slug, and generates the
    # description and anchor embedding from +name+ before saving, so creation
    # only requires a name.
    #
    # @param params [Hash] concept attributes, either flat or already wrapped
    #   in +:concept+.
    # @option params [String] :name (required) the concept name (max 100 chars)
    # @option params [String] :description human-readable description
    # @option params [Integer] :parent_id ID of the parent concept
    # @option params [Float] :similarity_threshold cutoff between 0.0 and 1.0
    # @option params [Float] :score ranking score for the concept
    # @param opts [Hash] per-request options.
    # @option opts [String] :api_key override the API key for this request.
    # @option opts [APIRequestor] :requestor a custom requestor to use.
    # @return [AdminConcept] the created concept (HTTP 201).
    # @raise [InvalidRequestError] on HTTP 422 (validation errors).
    def self.create(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:post, resource_path, wrap_params(params), opts)
      construct_from(resp.parsed_body, requestor: requestor)
    end

    # Update an existing concept.
    #
    # Sends a +PUT+ to +/api/admin/concepts/:id+ with the attributes wrapped
    # in a +concept+ object. Changing +name+ or +description+ causes the API
    # to regenerate the concept's anchor embedding.
    #
    # @param id [Integer, String] the concept ID.
    # @param params [Hash] attributes to change, either flat or already
    #   wrapped in +:concept+. Same permitted keys as {.create}.
    # @param opts [Hash] per-request options.
    # @return [AdminConcept] the updated concept.
    # @raise [NotFoundError] on HTTP 404.
    # @raise [InvalidRequestError] on HTTP 422 (validation errors).
    def self.update(id, params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:put, "#{resource_path}/#{id}", wrap_params(params), opts)
      construct_from(resp.parsed_body, requestor: requestor)
    end

    # Queue a classification lookback for a concept.
    #
    # Sends a +POST+ to +/api/admin/concepts/:id/trigger_lookback+, enqueueing
    # a background job that classifies records published within the last
    # +days+ days. The requested +days+ must be positive and strictly greater
    # than the concept's current +max_lookback_days+, otherwise the API
    # responds with HTTP 422.
    #
    # @param id [Integer, String] the concept ID.
    # @param params [Hash] request body.
    # @option params [Integer] :days (required) how many days back to classify.
    # @param opts [Hash] per-request options.
    # @return [ForemObject] an object carrying a +message+ describing the
    #   queued lookback.
    # @raise [InvalidRequestError] on HTTP 422 when +days+ is not greater than
    #   both zero and the concept's +max_lookback_days+.
    #
    # @example
    #   client.admin_concepts.trigger_lookback(7, days: 40).message
    def self.trigger_lookback(id, params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:post, "#{resource_path}/#{id}/trigger_lookback", params, opts)
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Wrap flat attributes in the +concept+ object the API expects.
    #
    # Params that already carry a +:concept+ (or +"concept"+) key are passed
    # through untouched.
    #
    # @param params [Hash] the caller-supplied attributes.
    # @return [Hash] params wrapped in +concept+.
    def self.wrap_params(params)
      return params if params.key?(:concept) || params.key?("concept")

      { concept: params }
    end
    private_class_method :wrap_params

    # Queue a classification lookback for this concept instance.
    #
    # @param days [Integer] how many days back to classify. Must be positive
    #   and greater than this concept's +max_lookback_days+.
    # @param opts [Hash] per-request options.
    # @return [ForemObject] an object carrying a +message+.
    # @raise [InvalidRequestError] if the instance has no +id+, or on HTTP 422.
    #
    # @example
    #   concept = client.admin_concepts.retrieve(7)
    #   concept.trigger_lookback(90)
    def trigger_lookback(days, opts = {})
      requestor = opts[:requestor] || @requestor
      resp = request(:post, "#{resource_url}/trigger_lookback", { days: days }, opts)
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end
  end
end
