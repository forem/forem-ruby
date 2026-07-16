module Forem
  # Provides admin-level user creation and synchronization for a Forem
  # instance.
  #
  # Requires super_admin privileges. Sends an invitation email to the
  # provided email address.
  #
  # AdminUser exposes the privileged user-creation endpoint under
  # +/api/admin/users+ (postAdminUsersCreate). Unlike the regular User
  # resource, this resource is scoped to admin operations and requires an
  # admin API key to use. General retrieval and moderation of existing users
  # remains on {Forem::User}; identity and notification synchronization lives
  # here.
  #
  # Available operations (via mixins):
  #   - +Create+ — POST /api/admin/users
  #   - +link_identity+ — POST /api/admin/users/:user_id/identities
  #   - +bulk_link_identities+ — POST /api/admin/users/identities/bulk
  #   - +identities+ — GET /api/admin/users/:user_id/identities
  #   - +unlink_identity+ — DELETE /api/admin/users/:user_id/identities/:id
  #   - +update_notification_settings+ — PUT notification settings for a user
  #
  # @!method self.create(params = {}, opts = {})
  #   Invite a new user by email (postAdminUsersCreate).
  #
  #   Requires super_admin privileges. Sends an invitation email to the
  #   provided email address. The endpoint takes flat params — there is
  #   no +user:+ wrapper.
  #
  #   The Forem API generates the username from the email address, so
  #   passing +:username+ has no effect. Optional invite-customization
  #   parameters are also accepted: +:custom_invite_subject+,
  #   +:custom_invite_message+, +:custom_invite_footnote+.
  #
  #   The response body is intentionally empty (HTTP 200) — there is no
  #   created-user record returned.
  #
  #   @param params [Hash] request body
  #   @option params [String] :email (required) the email address to invite
  #   @option params [String] :name the user's display name
  #   @option params [String] :custom_invite_subject override the invite subject line
  #   @option params [String] :custom_invite_message override the invite body
  #   @option params [String] :custom_invite_footnote override the invite footer
  #   @param opts [Hash] per-request options
  #   @return [Forem::AdminUser] an empty record (the API returns no body)
  #
  # @example Create a new user as an admin (flat params)
  #   client.admin_users.create(
  #     email: "alice@example.com",
  #     name: "Alice Example"
  #   )
  #
  # @see Forem::User
  # @see https://developers.forem.com/api/v1
  class AdminUser < APIResource
    extend APIOperations::Create

    OBJECT_NAME = "admin_user"
    RESOURCE_PATH = "/api/admin/users"

    # Link an external provider identity to a user.
    #
    # @param user_id [Integer, String] the Forem user ID.
    # @param provider [String] the identity provider name.
    # @param uid [String] the provider's stable user identifier.
    # @param opts [Hash] per-request options.
    # @return [ForemObject] the linked identity.
    def self.link_identity(user_id, provider:, uid:, **opts)
      requestor = opts[:requestor]
      resp = request(
        :post,
        "#{resource_path}/#{user_id}/identities",
        { provider: provider, uid: uid },
        opts
      )
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Submit multiple external identity links in one request.
    #
    # @param provider [String] the identity provider shared by the identities.
    # @param identities [Array<Hash>] identity hashes containing +user_id+ and
    #   +uid+.
    # @param opts [Hash] per-request options.
    # @return [Array<ForemObject>] per-item results containing +user_id+,
    #   +status+, and an +error_code+ when that item fails.
    def self.bulk_link_identities(provider:, identities:, **opts)
      requestor = opts[:requestor]
      resp = request(
        :post,
        "#{resource_path}/identities/bulk",
        { provider: provider, identities: identities },
        opts
      )
      results = resp.parsed_body["results"] || []
      results.map do |result|
        ForemObject.construct_from(result, requestor: requestor)
      end
    end

    # List a user's linked external identities.
    #
    # @param user_id [Integer, String] the Forem user ID.
    # @param opts [Hash] per-request options.
    # @return [Array<ForemObject>] the user's linked identities.
    def self.identities(user_id, **opts)
      requestor = opts[:requestor]
      resp = request(:get, "#{resource_path}/#{user_id}/identities", {}, opts)
      identities = resp.parsed_body["identities"] || []
      identities.map do |identity|
        ForemObject.construct_from(identity, requestor: requestor)
      end
    end

    # Unlink an external identity from a user.
    #
    # @param user_id [Integer, String] the Forem user ID.
    # @param identity_id [Integer, String] the linked identity ID.
    # @param opts [Hash] per-request options.
    # @return [ForemObject, nil] the unlinked identity when returned by the
    #   API, otherwise +nil+ for an empty response.
    def self.unlink_identity(user_id, identity_id, **opts)
      requestor = opts[:requestor]
      resp = request(
        :delete,
        "#{resource_path}/#{user_id}/identities/#{identity_id}",
        {},
        opts
      )
      return nil unless resp.parsed_body

      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Update the email newsletter notification setting for a user.
    #
    # @param user_id [Integer, String] the Forem user ID.
    # @param email_newsletter [Boolean] whether newsletter email is enabled.
    # @param opts [Hash] per-request options.
    # @return [ForemObject] the updated notification setting.
    def self.update_notification_settings(user_id, email_newsletter:, **opts)
      requestor = opts[:requestor]
      resp = request(
        :put,
        "#{resource_path}/#{user_id}/notification_settings",
        { notification_setting: { email_newsletter: email_newsletter } },
        opts
      )
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end
  end
end
