module Forem
  module Services
    # Service for interacting with the Forem Badge Achievements API.
    #
    # A badge achievement is a badge awarded to a user; creating one awards the
    # badge and deleting one revokes it. These endpoints require an API key with
    # admin-level privileges.
    #
    # Access via {Client#badge_achievements}. All methods inject the client's
    # requestor automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-admin-api-key")
    #   client.badge_achievements.create(user_id: 123, badge_id: 45)
    #
    # @see BadgeAchievement
    # @see BadgeService
    # @see https://developers.forem.com/api/v1
    class BadgeAchievementService < BaseService
      # List badge achievements, most recently created first.
      #
      # Returns a fixed 50 records per page.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @param opts [Hash] per-request options
      # @return [ListObject<BadgeAchievement>] a page of achievements
      #
      # @example
      #   client.badge_achievements.list(page: 2)
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        BadgeAchievement.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single badge achievement by its numeric ID.
      #
      # @param id [Integer, String] the achievement ID
      # @param opts [Hash] per-request options
      # @return [BadgeAchievement] the achievement with the given ID
      # @raise [NotFoundError] on HTTP 404
      #
      # @example
      #   client.badge_achievements.retrieve(9876)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, opts = {})
        BadgeAchievement.retrieve(id, opts_with_requestor(opts))
      end

      # Award a badge to a user.
      #
      # @param params [Hash] achievement attributes
      # @option params [Integer] :user_id the user ID (required)
      # @option params [Integer] :badge_id the badge ID (required)
      # @option params [String] :rewarding_context_message_markdown a message
      #   shown with the award
      # @option params [Boolean] :include_default_description whether to show
      #   the badge's own description alongside the message (default true)
      # @param opts [Hash] per-request options
      # @return [BadgeAchievement] the newly created achievement
      # @raise [InvalidRequestError] on HTTP 422
      #
      # @example
      #   client.badge_achievements.create(
      #     user_id: 123,
      #     badge_id: 45
      #   )
      #
      # @see https://developers.forem.com/api/v1
      def create(params = {}, opts = {})
        BadgeAchievement.create(
          enveloped(:badge_achievement, params),
          opts_with_requestor(opts),
        )
      end

      # Revoke a badge by deleting the achievement.
      #
      # @param id [Integer, String] the achievement ID to delete
      # @param opts [Hash] per-request options
      # @return [nil] returns nil on success
      # @raise [NotFoundError] on HTTP 404
      #
      # @example
      #   client.badge_achievements.delete(9876)
      #
      # @see https://developers.forem.com/api/v1
      def delete(id, opts = {})
        BadgeAchievement.delete(id, opts_with_requestor(opts))
      end
    end
  end
end
