module Forem
  # Represents a follow relationship — a user, organization, or tag the
  # authenticated user follows.
  #
  # The +list+ endpoint returns followed tags only (the route is
  # +/api/follows/tags+). The +create+ endpoint follows users and/or
  # organizations in bulk.
  #
  # @example List the tags the authenticated user is following
  #   follows = client.follows.list(per_page: 10)
  #   follows.each { |f| puts f.name }
  #
  # @example Follow users in bulk
  #   client.follows.create(user_ids: [42, 99])
  #   #=> #<Forem::Follow {"outcome" => "followed 2 users"}>
  #
  # @example Follow organizations in bulk
  #   client.follows.create(organization_ids: [7])
  #
  # @example Combined call
  #   client.follows.create(user_ids: [42], organization_ids: [7])
  #
  # @see https://developers.forem.com/api/v1#/operations/getFollowedTags
  class Follow < APIResource
    OBJECT_NAME = "follow"
    RESOURCE_PATH = "/api/follows"

    # Return a paginated list of tags followed by the authenticated user.
    #
    # Requires authentication. Sends a GET request to +/api/follows/tags+
    # (the +list+ verb is mapped to the tags collection rather than the
    # base resource path on this endpoint).
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options
    # @return [Forem::ListObject<Forem::Follow>] paginated list of followed tags
    # @example
    #   follows = client.follows.list(per_page: 10)
    #   follows.each { |f| puts f.name }
    # @see https://developers.forem.com/api/v1#/operations/getFollowedTags
    def self.list(params = {}, opts = {})
      paginated_list("/api/follows/tags", params, opts)
    end

    # Follow one or more users and/or organizations on behalf of the
    # authenticated user.
    #
    # Sends a POST request to +/api/follows+. The Forem API does *not*
    # follow tags through this endpoint (unlike what {#list} returns). It
    # accepts:
    #
    # * +user_ids:+         — Array<Integer> of user IDs to follow
    # * +organization_ids:+ — Array<Integer> of organization IDs to follow
    #
    # The response is an outcome summary (e.g.
    # +{"outcome" => "followed 2 users"}+), not a full follow record.
    # If neither param is supplied, the API silently reports
    # +"followed 0 users"+ — pass +user_ids+ or +organization_ids+
    # explicitly.
    #
    # @param params [Hash] request body
    # @option params [Array<Integer>] :user_ids list of user IDs to follow
    # @option params [Array<Integer>] :organization_ids list of org IDs to follow
    # @param opts [Hash] per-request options
    # @return [Forem::Follow] the outcome object returned by the API
    # @example
    #   client.follows.create(user_ids: [42, 99])
    #   #=> #<Forem::Follow {"outcome" => "followed 2 users"}>
    # @see https://developers.forem.com/api/v1
    def self.create(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:post, resource_path, params, opts)
      construct_from(resp.parsed_body, requestor: requestor)
    end
  end
end
