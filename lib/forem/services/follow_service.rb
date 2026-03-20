module Forem
  module Services
    # Service for interacting with the Forem Follows API.
    #
    # Manages the tags and users that the authenticated user follows.
    # Access via {Client#follows}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   followed_tags = client.follows.list
    #   client.follows.create(followable_type: "Tag", followable_id: 5)
    #
    # @see Follow
    # @see https://developers.forem.com/api/v1#tag/follows
    class FollowService < BaseService
      # List tags followed by the authenticated user.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Array<Follow>] list of follow relationships for the current user
      #
      # @example
      #   client.follows.list
      #
      # @see https://developers.forem.com/api/v1#tag/follows/operation/getFollowedTags
      def list(params = {}, opts = {})
        Follow.list(params, opts_with_requestor(opts))
      end

      # Follow a tag or user.
      #
      # @param params [Hash] follow attributes
      # @option params [String] :followable_type the type to follow
      #   ("Tag", "User", or "Organization")
      # @option params [Integer] :followable_id the ID of the entity to follow
      # @param opts [Hash] per-request options
      # @return [Follow] the newly created follow relationship
      #
      # @example Follow a tag
      #   client.follows.create(followable_type: "Tag", followable_id: 5)
      #
      # @example Follow a user
      #   client.follows.create(followable_type: "User", followable_id: 99)
      #
      # @see https://developers.forem.com/api/v1#tag/follows/operation/followUser
      def create(params = {}, opts = {})
        Follow.create(params, opts_with_requestor(opts))
      end
    end
  end
end
