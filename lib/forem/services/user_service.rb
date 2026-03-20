module Forem
  module Services
    # Service for interacting with the Forem Users API.
    #
    # Access via {Client#users}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   me = client.users.me
    #   user = client.users.retrieve(42)
    #
    # @see User
    # @see https://developers.forem.com/api/v1#/operations/getUser
    class UserService < BaseService
      # Retrieve a single user by their numeric ID.
      #
      # @param id [Integer, String] the user ID, or the string "by_username"
      #   combined with the +:username+ param
      # @param opts [Hash] per-request options
      # @return [User] the user with the given ID
      #
      # @example
      #   client.users.retrieve(42)
      #
      # @see https://developers.forem.com/api/v1#/operations/getUser
      def retrieve(id, opts = {})
        User.retrieve(id, opts_with_requestor(opts))
      end

      # Retrieve the profile of the currently authenticated user.
      #
      # @param opts [Hash] per-request options
      # @return [User] the authenticated user's profile
      #
      # @example
      #   me = client.users.me
      #   puts me.username
      #
      # @see https://developers.forem.com/api/v1#/operations/getUserMe
      def me(opts = {})
        User.me(opts_with_requestor(opts))
      end

      # Search for users by name or username.
      #
      # @param params [Hash] query parameters
      # @option params [String] :term the search term
      # @param opts [Hash] per-request options
      # @return [Array<User>] users matching the search query
      #
      # @example
      #   client.users.search(term: "jane")
      #
      # @see https://developers.forem.com/api/v1#/operations/searchUser
      def search(params = {}, opts = {})
        User.search(params, opts_with_requestor(opts))
      end
    end
  end
end
