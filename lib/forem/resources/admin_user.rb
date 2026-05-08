module Forem
  # Provides admin-level user creation for a Forem instance.
  #
  # Requires super_admin privileges. Sends an invitation email to the
  # provided email address.
  #
  # AdminUser exposes the privileged user-creation endpoint under
  # +/api/admin/users+ (postAdminUsersCreate). Unlike the regular User
  # resource, this resource is scoped to admin operations and requires an
  # admin API key to use. It is intentionally limited to creation —
  # retrieval and management of existing users is handled through
  # {Forem::User}.
  #
  # Available operations (via mixins):
  #   - +Create+ — POST /api/admin/users
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
  end
end
