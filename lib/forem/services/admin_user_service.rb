module Forem
  module Services
    # Service for interacting with the Forem Admin Users API.
    #
    # Provides administrative operations on user accounts. These endpoints
    # require an API key with admin-level privileges.
    # Access via {Client#admin_users}. All methods inject the client's
    # requestor automatically so no additional configuration is required.
    #
    # @see AdminUser
    # @see https://developers.forem.com/api/v1#/operations/postAdminUsersCreate
    class AdminUserService < BaseService
      # List users via the admin API.
      #
      # @param params [Hash] query parameters (+:email+, +:username+,
      #   +:identity_provider+, +:identity_uid+, +:page+, +:per_page+)
      # @param opts [Hash] per-request options
      # @return [ListObject<AdminUser>] paginated list of users
      def list(params = {}, opts = {})
        AdminUser.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single user via the admin API.
      #
      # @param id [Integer, String] the Forem user ID
      # @param opts [Hash] per-request options
      # @return [AdminUser] the user record
      def retrieve(id, opts = {})
        AdminUser.retrieve(id, opts_with_requestor(opts))
      end

      # Invite a new user to the Forem instance.
      #
      # @param params [Hash] user attributes (+:email+, +:name+,
      #   +:custom_invite_subject+, +:custom_invite_message+,
      #   +:custom_invite_footnote+)
      # @param opts [Hash] per-request options
      # @return [AdminUser] empty record (API returns 200 with empty body)
      def create(params = {}, opts = {})
        AdminUser.create(params, opts_with_requestor(opts))
      end

      # Update a user's profile fields via the admin API.
      #
      # @param id [Integer, String] the Forem user ID
      # @param params [Hash] updatable fields (+:name+, +:username+, +:summary+,
      #   +:location+, +:website_url+)
      # @param opts [Hash] per-request options
      # @return [AdminUser] the updated user record
      def update(id, params = {}, opts = {})
        AdminUser.update(id, params, opts_with_requestor(opts))
      end

      # Directly update a user's email address.
      #
      # @param user_id [Integer, String] the Forem user ID
      # @param email [String] new email address
      # @param opts [Hash] per-request options
      # @return [ForemObject] +{ id:, email: }+
      def update_email(user_id, email:, **opts)
        AdminUser.update_email(user_id, email: email, **opts_with_requestor(opts))
      end

      # Update a user's moderation status.
      #
      # @param user_id [Integer, String] the Forem user ID
      # @param status [String] new moderation status
      # @param note [String, nil] optional moderation note
      # @param opts [Hash] per-request options
      # @return [ForemObject] +{ id:, status: }+
      def update_status(user_id, status:, note: nil, **opts)
        AdminUser.update_status(user_id, status: status, note: note, **opts_with_requestor(opts))
      end

      # Merge a duplicate user account into a surviving user account.
      #
      # @param user_id [Integer, String] surviving user ID
      # @param merge_user_id [Integer, String] user ID to merge and delete
      # @param opts [Hash] per-request options
      # @return [AdminUser] the surviving user record
      def merge(user_id, merge_user_id:, **opts)
        AdminUser.merge(user_id, merge_user_id: merge_user_id, **opts_with_requestor(opts))
      end

      # List admin moderation notes for a user.
      #
      # @param user_id [Integer, String] the Forem user ID
      # @param opts [Hash] per-request options
      # @return [Array<ForemObject>] admin notes
      def notes(user_id, **opts)
        AdminUser.notes(user_id, **opts_with_requestor(opts))
      end

      # Create an admin moderation note on a user.
      #
      # @param user_id [Integer, String] the Forem user ID
      # @param content [String] note content
      # @param reason [String, nil] optional note reason
      # @param opts [Hash] per-request options
      # @return [ForemObject] the created note
      def create_note(user_id, content:, reason: nil, **opts)
        AdminUser.create_note(user_id, content: content, reason: reason, **opts_with_requestor(opts))
      end

      # Link an external identity to a user.
      #
      # @param user_id [Integer, String] the Forem user ID.
      # @param provider [String] the identity provider name.
      # @param uid [String] the provider's stable user identifier.
      # @param opts [Hash] per-request options.
      # @return [ForemObject] the linked identity.
      def link_identity(user_id, provider:, uid:, **opts)
        AdminUser.link_identity(
          user_id,
          provider: provider,
          uid: uid,
          **opts_with_requestor(opts)
        )
      end

      # Submit multiple external identity links in one request.
      #
      # @param provider [String] the identity provider shared by the identities.
      # @param identities [Array<Hash>] identity hashes containing +user_id+ and
      #   +uid+.
      # @param opts [Hash] per-request options.
      # @return [Array<ForemObject>] per-item results containing +user_id+,
      #   +status+, and an +error_code+ when that item fails.
      def bulk_link_identities(provider:, identities:, **opts)
        AdminUser.bulk_link_identities(
          provider: provider,
          identities: identities,
          **opts_with_requestor(opts)
        )
      end

      # List a user's linked external identities.
      #
      # @param user_id [Integer, String] the Forem user ID.
      # @param opts [Hash] per-request options.
      # @return [Array<ForemObject>] the user's linked identities.
      def identities(user_id, **opts)
        AdminUser.identities(user_id, **opts_with_requestor(opts))
      end

      # Unlink an external identity from a user.
      #
      # @param user_id [Integer, String] the Forem user ID.
      # @param identity_id [Integer, String] the linked identity ID.
      # @param opts [Hash] per-request options.
      # @return [ForemObject, nil] the unlinked identity, or +nil+ for an empty
      #   response.
      def unlink_identity(user_id, identity_id, **opts)
        AdminUser.unlink_identity(
          user_id,
          identity_id,
          **opts_with_requestor(opts)
        )
      end

      # Update email notification settings for a user.
      #
      # @param user_id [Integer, String] the Forem user ID.
      # @param settings [Hash] notification setting columns to write.
      # @param opts [Hash] per-request options.
      # @return [ForemObject] the updated notification setting.
      def update_notification_settings(user_id, settings:, **opts)
        AdminUser.update_notification_settings(
          user_id,
          settings: settings,
          **opts_with_requestor(opts)
        )
      end
    end
  end
end
