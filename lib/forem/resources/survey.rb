module Forem
  # Represents a survey published on a Forem instance.
  #
  # Surveys are structured questionnaires that can be presented to community
  # members. They can be listed or retrieved individually. Survey responses
  # are exposed through two endpoints — {#poll_votes} for multiple-choice
  # poll selections and {#poll_text_responses} for free-text answers.
  #
  # The +/api/surveys/{id}/responses+ endpoint that earlier versions of
  # this gem hit no longer exists in the Forem API; it was replaced by
  # those two cursor-paginated endpoints.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/surveys
  #   - +Retrieve+ — GET /api/surveys/:id_or_slug (getSurveyByIdOrSlug)
  #
  # == Survey Fields
  #
  # - +id+ (Integer)
  # - +title+ (String)
  # - +slug+ (String)
  # - +survey_type_of+ (String) — Survey category
  # - +active+ (Boolean) — Whether the survey is currently active
  #
  # == Authentication
  #
  # All survey endpoints require an admin API key.
  #
  # @example List active surveys
  #   surveys = client.surveys.list(active: true)
  #   surveys.each { |s| puts s.title }
  #
  # @example Retrieve a specific survey by id or slug
  #   survey = client.surveys.retrieve(3)
  #   survey = client.surveys.retrieve("my-survey-slug")
  #
  # @example Iterate every poll vote across all pages
  #   survey = client.surveys.retrieve(3)
  #   survey.poll_votes.auto_paging_each { |v| puts v.poll_option_id }
  #
  # @see https://developers.forem.com/api/v1
  class Survey < APIResource
    extend APIOperations::List
    extend APIOperations::Retrieve

    OBJECT_NAME = "survey"
    RESOURCE_PATH = "/api/surveys"

    # Return the multiple-choice poll selections recorded for this survey.
    #
    # Sends a GET request to +/api/surveys/:id_or_slug/poll_votes+.
    # Pagination is cursor-based — pass the last seen vote id as +:after+
    # (or use {Forem::ListObject#auto_paging_each}, which threads the
    # cursor automatically).
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :after return only votes with id strictly
    #   greater than this value (cursor)
    # @option params [Integer] :per_page page size (default 30)
    # @param opts [Hash] per-request options
    # @return [Forem::ListObject<Forem::ForemObject>] cursor-paginated list
    #   of poll-vote objects.
    # @example
    #   survey = client.surveys.retrieve(3)
    #   survey.poll_votes.auto_paging_each { |v| puts v.id }
    # @see https://developers.forem.com/api/v1
    def poll_votes(params = {}, opts = {})
      opts = opts.dup
      opts[:requestor] ||= @requestor
      Forem::ForemObject.cursor_list("#{resource_url}/poll_votes", params, opts)
    end

    # Return the free-text answers recorded for this survey.
    #
    # Sends a GET request to +/api/surveys/:id_or_slug/poll_text_responses+.
    # Cursor-paginated by +:after+ on the last seen response id; see
    # {#poll_votes} for paging details.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :after return only responses with id
    #   strictly greater than this value (cursor)
    # @option params [Integer] :per_page page size (default 30)
    # @param opts [Hash] per-request options
    # @return [Forem::ListObject<Forem::ForemObject>] cursor-paginated list
    #   of poll text-response objects.
    # @example
    #   survey = client.surveys.retrieve(3)
    #   survey.poll_text_responses.each { |r| puts r.text_content }
    # @see https://developers.forem.com/api/v1
    def poll_text_responses(params = {}, opts = {})
      opts = opts.dup
      opts[:requestor] ||= @requestor
      Forem::ForemObject.cursor_list("#{resource_url}/poll_text_responses", params, opts)
    end
  end
end
