module Forem
  module Services
    # Service for interacting with the Forem Admin Users API.
    #
    # Provides administrative operations on user accounts. These endpoints
    # require an API key with admin-level privileges.
    # Access via {Client#admin_users}. All methods inject the client's
    # requestor automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("admin-api-key")
    #   user = client.admin_users.create(
    #     email: "newuser@example.com",
    #     name: "New User"
    #   )
    #
    # @see AdminUser
    # @see https://developers.forem.com/api/v1#/operations/postAdminUsersCreate
    class AdminUserService < BaseService
      # Invite a new user to the Forem instance.
      #
      # Creates a user account and sends them an invitation email.
      # Requires admin privileges.
      #
      # @param params [Hash] user attributes
      # @option params [String] :email the new user's email address (required)
      # @option params [String] :name display name for the new user
      # @option params [String] :username desired username (generated if omitted)
      # @param opts [Hash] per-request options
      # @return [AdminUser] the newly created user record
      #
      # @example
      #   client.admin_users.create(
      #     email: "jane@example.com",
      #     name: "Jane Doe"
      #   )
      #
      # @see https://developers.forem.com/api/v1#/operations/postAdminUsersCreate
      def create(params = {}, opts = {})
        AdminUser.create(params, opts_with_requestor(opts))
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

      # Update the email newsletter notification setting for a user.
      #
      # @param user_id [Integer, String] the Forem user ID.
      # @param email_newsletter [Boolean] whether newsletter email is enabled.
      # @param opts [Hash] per-request options.
      # @return [ForemObject] the updated notification setting.
      def update_notification_settings(user_id, email_newsletter:, **opts)
        AdminUser.update_notification_settings(
          user_id,
          email_newsletter: email_newsletter,
          **opts_with_requestor(opts)
        )
      end
    end
  end
end
