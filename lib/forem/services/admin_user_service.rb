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
    end
  end
end
