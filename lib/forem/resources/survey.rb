module Forem
  # Represents a survey published on a Forem instance.
  #
  # Surveys contain nested polls with poll options.
  #
  # Surveys are structured questionnaires that can be presented to community
  # members. They can be listed or retrieved individually. Individual survey
  # responses can be accessed through the +responses+ instance method.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/surveys
  #   - +Retrieve+ — GET /api/surveys/:id (getSurveyByIdOrSlug)
  #
  # == Survey Fields
  #
  # - +id+ (Integer)
  # - +title+ (String)
  # - +slug+ (String)
  # - +survey_type_of+ (String) — Survey category
  # - +active+ (Boolean) — Whether the survey is currently active
  #
  # @!method self.retrieve(id, opts = {})
  #   Retrieve a survey by numeric ID or slug (getSurveyByIdOrSlug).
  #
  #   The +id+ parameter can be a numeric ID or a slug string. Returns the
  #   survey with all nested polls and poll options.
  #
  #   @param id [Integer, String] numeric ID or slug of the survey
  #   @param opts [Hash] per-request options (e.g., +:api_key+)
  #   @return [Forem::Survey] the matching survey with nested polls and options
  #
  # @example List all surveys
  #   surveys = Forem::Survey.list
  #   surveys.data.each { |s| puts s.name }
  #
  # @example Retrieve a specific survey
  #   survey = Forem::Survey.retrieve(3)
  #   puts survey.name
  #
  # @example Retrieve survey responses
  #   survey = Forem::Survey.retrieve(3)
  #   survey.responses.each { |r| puts r.inspect }
  #
  # @see https://developers.forem.com/api/v1
  class Survey < APIResource
    extend APIOperations::List
    extend APIOperations::Retrieve

    OBJECT_NAME = "survey"
    RESOURCE_PATH = "/api/surveys"

    # Return the collected responses for this survey.
    #
    # Returns poll votes and text responses for this survey.
    #
    # Sends a GET request to +/api/surveys/:id/responses+.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::ForemObject>] list of response objects for this survey
    # @example
    #   survey = Forem::Survey.retrieve(3)
    #   survey.responses.each { |r| puts r.answers.inspect }
    # @see https://developers.forem.com/api/v1
    def responses(params = {}, opts = {})
      resp = request(:get, "#{resource_url}/responses", params, opts)
      (resp.parsed_body || []).map { |item| Forem::ForemObject.construct_from(item) }
    end
  end
end
