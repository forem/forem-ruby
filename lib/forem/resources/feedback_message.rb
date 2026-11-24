module Forem
  # Represents a moderation feedback message (abuse/vomit/misc report).
  #
  # Supports admin status updates via +PUT /api/feedback_messages/:id+.
  # Requires admin privileges.
  #
  # @example Update a feedback message status
  #   msg = client.feedback_messages.update(42, status: "Resolved")
  #   puts msg.status
  #
  # @see https://developers.forem.com/api/v1
  class FeedbackMessage < APIResource
    extend APIOperations::Update
    include APIOperations::Save

    OBJECT_NAME = "feedback_message"
    RESOURCE_PATH = "/api/feedback_messages"

    # Update a feedback message.
    #
    # Automatically wraps flat parameters under +:feedback_message+ as required
    # by the Forem API. Already-wrapped hashes are passed through untouched.
    #
    # @param id [Integer, String] the feedback message ID
    # @param params [Hash] attributes to update (e.g. +{ status: "Resolved" }+)
    # @param opts [Hash] per-request options
    # @return [Forem::FeedbackMessage] the updated feedback message
    def self.update(id, params = {}, opts = {})
      payload = wrap_params(params)
      super(id, payload, opts)
    end

    # Save updates on this feedback message instance.
    #
    # @param params [Hash] attributes to update
    # @param opts [Hash] per-request options
    # @return [Forem::FeedbackMessage] updated feedback message
    def save(params = {}, **opts)
      payload = params.key?(:feedback_message) || params.key?("feedback_message") ? params : { feedback_message: params }
      super(payload, **opts)
    end

    def self.wrap_params(params)
      return params if params.key?(:feedback_message) || params.key?("feedback_message")

      { feedback_message: params }
    end
    private_class_method :wrap_params
  end
end
