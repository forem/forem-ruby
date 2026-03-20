module Forem
  # Represents a Forem user account.
  #
  # Users can be retrieved by ID or by looking up the currently authenticated
  # user. Admin-level operations (suspend, unsuspend, flag as spam, etc.) are
  # also exposed as instance methods and require an admin API key.
  #
  # Available operations (via mixins):
  #   - +Retrieve+ — GET /api/users/:id
  #
  # Note: the +id+ parameter passed to +retrieve+ can be a numeric ID or a
  # username string.
  #
  # @example Retrieve the authenticated user
  #   me = Forem::User.me
  #   puts "Hello, #{me.name}!"
  #
  # @example Retrieve a user by ID
  #   user = Forem::User.retrieve(12345)
  #   puts user.username
  #
  # @example Search users by name
  #   results = Forem::User.search(q: "alice")
  #   results.each { |u| puts u.username }
  #
  # @see https://developers.forem.com/api/v1#/operations/getUser
  class User < APIResource
    extend APIOperations::Retrieve

    OBJECT_NAME = "user"
    RESOURCE_PATH = "/api/users"

    # Return the currently authenticated user's profile.
    #
    # Returns extended user info including +email+ (if the user allows it
    # on their profile).
    #
    # Sends a GET request to +/api/users/me+.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::User] the authenticated user
    # @example
    #   me = Forem::User.me
    #   puts "Logged in as #{me.username}"
    # @see https://developers.forem.com/api/v1#/operations/getUserMe
    def self.me(opts = {})
      resp = request(:get, "/api/users/me", {}, opts)
      construct_from(resp.parsed_body)
    end

    # Search for users by name or username.
    #
    # Sends a GET request to +/api/users/search+.
    #
    # @param params [Hash] query parameters
    # @option params [String] :q search term (name or username prefix)
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::User>] users matching the search query
    # @example
    #   users = Forem::User.search(q: "alice")
    #   users.each { |u| puts u.username }
    # @see https://developers.forem.com/api/v1
    def self.search(params = {}, opts = {})
      resp = request(:get, "/api/users/search", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    # Unpublish all articles and comments authored by this user.
    #
    # Unpublishes all articles by this user.
    #
    # Sends a PUT request to +/api/users/:id/unpublish+. Requires admin privileges.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   user = Forem::User.retrieve(42)
    #   user.unpublish
    # @see https://developers.forem.com/api/v1#/operations/unpublishUser
    def unpublish(opts = {})
      request(:put, "#{resource_url}/unpublish", {}, opts)
    end

    # Suspend this user, preventing them from logging in or posting.
    #
    # Prevents new posts and comments but does not delete existing content.
    # The user is not notified in the UI.
    #
    # Sends a PUT request to +/api/users/:id/suspend+. Requires admin privileges.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   user = Forem::User.retrieve(42)
    #   user.suspend
    # @see https://developers.forem.com/api/v1#/operations/suspendUser
    def suspend(opts = {})
      request(:put, "#{resource_url}/suspend", {}, opts)
    end

    # Remove the suspension from this user, restoring their access.
    #
    # Sends a DELETE request to +/api/users/:id/suspend+. Requires admin privileges.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   user = Forem::User.retrieve(42)
    #   user.unsuspend
    # @see https://developers.forem.com/api/v1#/operations/suspendUser
    def unsuspend(opts = {})
      request(:delete, "#{resource_url}/suspend", {}, opts)
    end

    # Apply the "limited" role to this user, restricting their posting ability.
    #
    # Sends a PUT request to +/api/users/:id/limited+. Requires admin privileges.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   user = Forem::User.retrieve(42)
    #   user.add_limited
    # @see https://developers.forem.com/api/v1
    def add_limited(opts = {})
      request(:put, "#{resource_url}/limited", {}, opts)
    end

    # Remove the "limited" role from this user.
    #
    # Sends a DELETE request to +/api/users/:id/limited+. Requires admin privileges.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   user = Forem::User.retrieve(42)
    #   user.remove_limited
    # @see https://developers.forem.com/api/v1
    def remove_limited(opts = {})
      request(:delete, "#{resource_url}/limited", {}, opts)
    end

    # Flag this user as a spam account.
    #
    # Prevents new posts and comments but does not delete existing content.
    # The user is not notified in the UI.
    #
    # Sends a PUT request to +/api/users/:id/spam+. Requires admin privileges.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   user = Forem::User.retrieve(42)
    #   user.add_spam
    # @see https://developers.forem.com/api/v1#/operations/spamUser
    def add_spam(opts = {})
      request(:put, "#{resource_url}/spam", {}, opts)
    end

    # Remove the spam flag from this user.
    #
    # Sends a DELETE request to +/api/users/:id/spam+. Requires admin privileges.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   user = Forem::User.retrieve(42)
    #   user.remove_spam
    # @see https://developers.forem.com/api/v1#/operations/spamUser
    def remove_spam(opts = {})
      request(:delete, "#{resource_url}/spam", {}, opts)
    end

    # Grant the "trusted" role to this user, giving them elevated moderation privileges.
    #
    # Sends a PUT request to +/api/users/:id/trusted+. Requires admin privileges.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   user = Forem::User.retrieve(42)
    #   user.add_trusted
    # @see https://developers.forem.com/api/v1
    def add_trusted(opts = {})
      request(:put, "#{resource_url}/trusted", {}, opts)
    end

    # Remove the "trusted" role from this user.
    #
    # Sends a DELETE request to +/api/users/:id/trusted+. Requires admin privileges.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   user = Forem::User.retrieve(42)
    #   user.remove_trusted
    # @see https://developers.forem.com/api/v1
    def remove_trusted(opts = {})
      request(:delete, "#{resource_url}/trusted", {}, opts)
    end
  end
end
