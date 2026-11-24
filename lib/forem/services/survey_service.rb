module Forem
  module Services
    # Service for interacting with the Forem Surveys API.
    #
    # Surveys are questionnaires presented to community members.
    # Access via {Client#surveys}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @see Survey
    # @see https://developers.forem.com/api/v1#/operations/getSurveyByIdOrSlug
    class SurveyService < BaseService
      # List all surveys.
      #
      # @param params [Hash] query parameters (+:active+, +:page+, +:per_page+)
      # @param opts [Hash] per-request options
      # @return [ListObject<Survey>] list of surveys
      def list(params = {}, opts = {})
        Survey.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single survey by its numeric ID or slug.
      #
      # @param id_or_slug [Integer, String] the survey ID or slug
      # @param opts [Hash] per-request options
      # @return [Survey] the survey
      def retrieve(id_or_slug, opts = {})
        Survey.retrieve(id_or_slug, opts_with_requestor(opts))
      end

      # Create a new survey (admin only).
      #
      # Accepts flat attributes or a +survey:+-wrapped hash.
      #
      # @param params [Hash] survey attributes
      # @param opts [Hash] per-request options
      # @return [Survey] the newly created survey
      def create(params = {}, opts = {})
        Survey.create(params, opts_with_requestor(opts))
      end

      # Update an existing survey by ID or slug (admin only).
      #
      # @param id_or_slug [Integer, String] the survey ID or slug
      # @param params [Hash] attributes to update
      # @param opts [Hash] per-request options
      # @return [Survey] the updated survey
      def update(id_or_slug, params = {}, opts = {})
        Survey.update(id_or_slug, params, opts_with_requestor(opts))
      end

      # Delete a survey by ID or slug (admin only).
      #
      # @param id_or_slug [Integer, String] the survey ID or slug
      # @param opts [Hash] per-request options
      # @return [nil] returns nil on 204 No Content
      def delete(id_or_slug, opts = {})
        Survey.delete(id_or_slug, opts_with_requestor(opts))
      end

      # Return cursor-paginated poll votes for a survey.
      #
      # @param id_or_slug [Integer, String] the survey ID or slug
      # @param params [Hash] query parameters (+:after+, +:per_page+)
      # @param opts [Hash] per-request options
      # @return [ListObject<ForemObject>] cursor-paginated poll votes
      def poll_votes(id_or_slug, params = {}, opts = {})
        Survey.poll_votes(id_or_slug, params, opts_with_requestor(opts))
      end

      # Return cursor-paginated poll text responses for a survey.
      #
      # @param id_or_slug [Integer, String] the survey ID or slug
      # @param params [Hash] query parameters (+:after+, +:per_page+)
      # @param opts [Hash] per-request options
      # @return [ListObject<ForemObject>] cursor-paginated text responses
      def poll_text_responses(id_or_slug, params = {}, opts = {})
        Survey.poll_text_responses(id_or_slug, params, opts_with_requestor(opts))
      end
    end
  end
end
