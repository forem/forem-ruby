module Forem
  module Services
    # Service for interacting with the Forem Follows API.
    #
    # Lists the tags the authenticated user follows, and follows users or
    # organizations in bulk.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   followed_tags = client.follows.list
    #   client.follows.create(user_ids: [42, 99])
    #
    # @see Follow
    # @see https://developers.forem.com/api/v1#/operations/getFollowedTags
    class FollowService < BaseService
      # List tags followed by the authenticated user.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Forem::ListObject<Forem::Follow>] paginated list of
      #   followed tags for the current user.
      #
      # @example
      #   client.follows.list
      #
      # @see https://developers.forem.com/api/v1#/operations/getFollowedTags
      def list(params = {}, opts = {})
        Follow.list(params, opts_with_requestor(opts))
      end

      # Follow one or more users and/or organizations.
      #
      # The Forem API takes flat +user_ids+ and/or +organization_ids+
      # arrays — not a wrapped +follows:+ key, despite the resource name.
      # Tags are not followed through this endpoint.
      #
      # @param params [Hash] follow attributes
      # @option params [Array<Integer>] :user_ids user IDs to follow
      # @option params [Array<Integer>] :organization_ids org IDs to follow
      # @param opts [Hash] per-request options
      # @return [Forem::Follow] outcome object (e.g.
      #   <tt>#<Forem::Follow {"outcome" => "followed 2 users"}></tt>).
      #
      # @example Follow users in bulk
      #   client.follows.create(user_ids: [42, 99])
      #
      # @example Follow organizations
      #   client.follows.create(organization_ids: [7])
      #
      # @example Combined
      #   client.follows.create(user_ids: [42], organization_ids: [7])
      #
      # @see https://developers.forem.com/api/v1
      def create(params = {}, opts = {})
        Follow.create(params, opts_with_requestor(opts))
      end
    end
  end
end
