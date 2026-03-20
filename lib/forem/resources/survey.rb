module Forem
  # Represents a survey published on a Forem instance.
  #
  # Surveys are structured questionnaires that can be presented to community
  # members. They can be listed or retrieved individually. Individual survey
  # responses can be accessed through the +responses+ instance method.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/surveys
  #   - +Retrieve+ — GET /api/surveys/:id
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
