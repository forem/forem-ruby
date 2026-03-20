module Forem
  module Services
    # Service for interacting with the Forem Surveys API.
    #
    # Surveys are questionnaires presented to community members.
    # Access via {Client#surveys}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   surveys = client.surveys.list
    #   survey  = client.surveys.retrieve(8)
    #
    # @see Survey
    # @see https://developers.forem.com/api/v1
    class SurveyService < BaseService
      # List all surveys.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Array<Survey>] list of surveys
      #
      # @example
      #   client.surveys.list
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        Survey.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single survey by its numeric ID.
      #
      # @param id [Integer, String] the survey ID
      # @param opts [Hash] per-request options
      # @return [Survey] the survey with the given ID
      #
      # @example
      #   client.surveys.retrieve(8)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, opts = {})
        Survey.retrieve(id, opts_with_requestor(opts))
      end
    end
  end
end
