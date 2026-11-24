module Forem
  # Represents a survey published on a Forem instance.
  #
  # Surveys are structured questionnaires that can be presented to community
  # members. They support full CRUD operations plus two cursor-paginated
  # response endpoints — {#poll_votes} for multiple-choice poll selections and
  # {#poll_text_responses} for free-text answers.
  #
  # Available operations:
  #   - +List+                — GET /api/surveys
  #   - +Create+              — POST /api/surveys
  #   - +Retrieve+            — GET /api/surveys/:id_or_slug
  #   - +Update+              — PUT /api/surveys/:id_or_slug
  #   - +Delete+              — DELETE /api/surveys/:id_or_slug
  #   - +Save+                — instance-level save (create or update)
  #   - +poll_votes+          — GET /api/surveys/:id_or_slug/poll_votes
  #   - +poll_text_responses+ — GET /api/surveys/:id_or_slug/poll_text_responses
  #
  # == Authentication
  #
  # All survey endpoints require an admin API key.
  #
  # @see https://developers.forem.com/api/v1
  class Survey < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Delete
    include APIOperations::Save

    OBJECT_NAME = "survey"
    RESOURCE_PATH = "/api/surveys"

    # Create a new survey.
    #
    # Automatically wraps flat parameters under +:survey+ as required by the
    # Forem API. Already-wrapped hashes are passed through untouched.
    #
    # @param params [Hash] survey attributes (flat or wrapped under +:survey+)
    # @param opts [Hash] per-request options
    # @return [Forem::Survey] the newly created survey
    def self.create(params = {}, opts = {})
      payload = params.key?(:survey) || params.key?("survey") ? params : { survey: params }
      super(payload, opts)
    end

    # Update an existing survey by ID or slug.
    #
    # Automatically wraps flat parameters under +:survey+ as required by the
    # Forem API. Already-wrapped hashes are passed through untouched.
    #
    # @param id [Integer, String] survey ID or slug
    # @param params [Hash] attributes to update
    # @param opts [Hash] per-request options
    # @return [Forem::Survey] the updated survey
    def self.update(id, params = {}, opts = {})
      payload = params.key?(:survey) || params.key?("survey") ? params : { survey: params }
      super(id, payload, opts)
    end

    # Return multiple-choice poll votes for a survey by ID or slug.
    #
    # @param id_or_slug [Integer, String] survey ID or slug
    # @param params [Hash] query parameters (+:after+, +:per_page+)
    # @param opts [Hash] per-request options
    # @return [Forem::ListObject<Forem::ForemObject>] cursor-paginated poll votes
    def self.poll_votes(id_or_slug, params = {}, opts = {})
      Forem::ForemObject.cursor_list("#{resource_path}/#{id_or_slug}/poll_votes", params, opts)
    end

    # Return free-text responses for a survey by ID or slug.
    #
    # @param id_or_slug [Integer, String] survey ID or slug
    # @param params [Hash] query parameters (+:after+, +:per_page+)
    # @param opts [Hash] per-request options
    # @return [Forem::ListObject<Forem::ForemObject>] cursor-paginated text responses
    def self.poll_text_responses(id_or_slug, params = {}, opts = {})
      Forem::ForemObject.cursor_list("#{resource_path}/#{id_or_slug}/poll_text_responses", params, opts)
    end

    # Save updates on this survey instance.
    #
    # @param params [Hash] attributes to update
    # @param opts [Hash] per-request options
    # @return [Forem::Survey] updated survey instance
    def save(params = {}, **opts)
      payload = params.key?(:survey) || params.key?("survey") ? params : { survey: params }
      super(payload, **opts)
    end

    # Return the multiple-choice poll selections recorded for this survey.
    #
    # Sends a GET request to +/api/surveys/:id_or_slug/poll_votes+.
    #
    # @param params [Hash] query parameters (+:after+, +:per_page+)
    # @param opts [Hash] per-request options
    # @return [Forem::ListObject<Forem::ForemObject>] cursor-paginated list
    def poll_votes(params = {}, opts = {})
      opts = opts.dup
      opts[:requestor] ||= @requestor
      Forem::ForemObject.cursor_list("#{resource_url}/poll_votes", params, opts)
    end

    # Return the free-text answers recorded for this survey.
    #
    # Sends a GET request to +/api/surveys/:id_or_slug/poll_text_responses+.
    #
    # @param params [Hash] query parameters (+:after+, +:per_page+)
    # @param opts [Hash] per-request options
    # @return [Forem::ListObject<Forem::ForemObject>] cursor-paginated list
    def poll_text_responses(params = {}, opts = {})
      opts = opts.dup
      opts[:requestor] ||= @requestor
      Forem::ForemObject.cursor_list("#{resource_url}/poll_text_responses", params, opts)
    end
  end
end
