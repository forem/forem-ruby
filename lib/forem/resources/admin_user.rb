module Forem
  # Provides admin-level user creation for a Forem instance.
  #
  # AdminUser exposes the privileged user-creation endpoint under
  # +/api/admin/users+. Unlike the regular User resource, this resource
  # is scoped to admin operations and requires an admin API key to use.
  # It is intentionally limited to creation — retrieval and management of
  # existing users is handled through {Forem::User}.
  #
  # Available operations (via mixins):
  #   - +Create+ — POST /api/admin/users
  #
  # @example Create a new user as an admin
  #   user = Forem::AdminUser.create(
  #     user: {
  #       name: "Alice Example",
  #       username: "alice",
  #       email: "alice@example.com"
  #     }
  #   )
  #   puts user.id
  #
  # @see Forem::User
  # @see https://developers.forem.com/api/v1
  class AdminUser < APIResource
    extend APIOperations::Create

    OBJECT_NAME = "admin_user"
    RESOURCE_PATH = "/api/admin/users"
  end
end
