module Forem
  module Services
    # Service for interacting with the Forem Badges API.
    #
    # Badges are awards that can be given to users. These endpoints require
    # an API key with admin-level privileges.
    #
    # Access via {Client#badges}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-admin-api-key")
    #   badges = client.badges.list
    #   badge  = client.badges.retrieve(45)
    #
    # @see Badge
    # @see BadgeAchievementService for awarding a badge to a user
    # @see https://developers.forem.com/api/v1
    class BadgeService < BaseService
      # List badges, most recently created first.
      #
      # Returns a fixed 50 records per page.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @param opts [Hash] per-request options
      # @return [ListObject<Badge>] a page of badges
      #
      # @example
      #   client.badges.list(page: 2)
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        Badge.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single badge by its numeric ID.
      #
      # @param id [Integer, String] the badge ID
      # @param opts [Hash] per-request options
      # @return [Badge] the badge with the given ID
      # @raise [NotFoundError] on HTTP 404
      #
      # @example
      #   client.badges.retrieve(45)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, opts = {})
        Badge.retrieve(id, opts_with_requestor(opts))
      end

      # Create a new badge.
      #
      # @param params [Hash] badge attributes
      # @option params [String] :title badge title (must be unique)
      # @option params [String] :description badge description
      # @option params [String] :remote_badge_image_url URL to fetch the badge
      #   image from
      # @option params [Integer] :credits_awarded credits granted alongside the
      #   badge (default 0)
      # @option params [Boolean] :allow_multiple_awards whether the badge can
      #   be awarded to the same user more than once (default false)
      # @param opts [Hash] per-request options
      # @return [Badge] the newly created badge
      # @raise [InvalidRequestError] on HTTP 422 (validation errors)
      #
      # @example
      #   client.badges.create(
      #     title: "Forem Contributor",
      #     description: "Contributed an article",
      #     remote_badge_image_url: "https://example.com/badge.png"
      #   )
      #
      # @see https://developers.forem.com/api/v1
      def create(params = {}, opts = {})
        Badge.create(enveloped(:badge, params), opts_with_requestor(opts))
      end

      # Update an existing badge.
      #
      # @param id [Integer, String] the badge ID to update
      # @param params [Hash] badge attributes to change
      # @option params [String] :title new title
      # @option params [String] :description new description
      # @option params [Integer] :credits_awarded new credit amount
      # @option params [Boolean] :allow_multiple_awards new multiple-award
      #   setting
      # @param opts [Hash] per-request options
      # @return [Badge] the updated badge
      # @raise [NotFoundError] on HTTP 404
      # @raise [InvalidRequestError] on HTTP 422 (validation errors)
      #
      # @example
      #   client.badges.update(45, description: "Updated description")
      #
      # @see https://developers.forem.com/api/v1
      def update(id, params = {}, opts = {})
        Badge.update(id, enveloped(:badge, params), opts_with_requestor(opts))
      end

      # Delete a badge.
      #
      # @param id [Integer, String] the badge ID to delete
      # @param opts [Hash] per-request options
      # @return [nil] returns nil on success
      # @raise [NotFoundError] on HTTP 404
      #
      # @example
      #   client.badges.delete(45)
      #
      # @see https://developers.forem.com/api/v1
      def delete(id, opts = {})
        Badge.delete(id, opts_with_requestor(opts))
      end
    end
  end
end
