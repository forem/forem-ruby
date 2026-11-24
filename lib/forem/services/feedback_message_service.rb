module Forem
  module Services
    # Service for interacting with the Forem Feedback Messages API.
    #
    # Access via {Client#feedback_messages}.
    #
    # @see FeedbackMessage
    # @see https://developers.forem.com/api/v1
    class FeedbackMessageService < BaseService
      # Update a moderation feedback message (admin only).
      #
      # Accepts either flat attributes (+{ status: "Resolved" }+) or wrapped
      # (+{ feedback_message: { status: "Resolved" } }+).
      #
      # @param id [Integer, String] feedback message ID
      # @param params [Hash] attributes to update
      # @param opts [Hash] per-request options
      # @return [FeedbackMessage] the updated feedback message
      def update(id, params = {}, opts = {})
        FeedbackMessage.update(id, params, opts_with_requestor(opts))
      end
    end
  end
end
