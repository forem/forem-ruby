module Forem
  module Services
    # Service for interacting with the Forem Followers API.
    #
    # Lists the users who follow the authenticated user.
    # Access via {Client#followers}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   followers = client.followers.list(per_page: 50)
    #
    # @see Follower
    # @see https://developers.forem.com/api/v1#/operations/getFollowers
    class FollowerService < BaseService
      # List users who follow the authenticated user.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @option params [String] :sort sort order ("created_at" for most recent first)
      # @param opts [Hash] per-request options
      # @return [Array<Follower>] list of followers for the authenticated user
      #
      # @example
      #   client.followers.list(per_page: 100, sort: "created_at")
      #
      # @see https://developers.forem.com/api/v1#/operations/getFollowers
      def list(params = {}, opts = {})
        Follower.list(params, opts_with_requestor(opts))
      end
    end
  end
end
