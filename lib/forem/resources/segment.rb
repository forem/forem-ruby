module Forem
  # Represents a user segment used for targeted content delivery on Forem.
  #
  # Audience segments for billboard targeting. The API only permits managing
  # segments you create yourself.
  #
  # Segments are named groups of users that can be targeted with specific
  # billboards or other content. Admins can create and delete segments, list
  # their members, and add or remove users from them. Managing segments
  # requires an admin API key.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/segments          (getSegments)
  #   - +Create+   — POST /api/segments         (createSegment)
  #   - +Retrieve+ — GET /api/segments/:id
  #   - +Delete+   — instance-level delete (DELETE /api/segments/:id)
  #
  # == Segment Fields
  #
  # - +id+ (Integer) — The segment ID
  # - +type_of+ (String) — Marks segment as manually managed
  # - +user_count+ (Integer) — Current number of users in the segment
  #
  # @example List all segments
  #   segments = client.segments.list
  #   segments.each { |s| puts s.id }
  #
  # @example Create a segment (no params accepted — the API ignores anything passed)
  #   segment = client.segments.create
  #   #=> #<Forem::Segment id=14 type_of="manual">
  #
  # @example List users in a segment
  #   segment = client.segments.retrieve(5)
  #   segment.users.auto_paging_each { |u| puts u.username }
  #
  # @see https://developers.forem.com/api/v1
  class Segment < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    include APIOperations::Delete

    OBJECT_NAME = "segment"
    RESOURCE_PATH = "/api/segments"

    # Return the users who belong to this segment.
    #
    # Returns users in this segment. Default: 30 per page, max: 1000.
    #
    # Sends a GET request to +/api/segments/:id/users+ (getUsersInSegment).
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30, max: 1000)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ListObject<Forem::User>] paginated list of users
    #   belonging to this segment.
    # @example
    #   segment = client.segments.retrieve(5)
    #   segment.users.auto_paging_each { |u| puts u.username }
    # @see https://developers.forem.com/api/v1
    def users(params = {}, opts = {})
      opts = opts.dup
      opts[:requestor] ||= @requestor
      Forem::User.paginated_list("#{resource_url}/users", params, opts)
    end

    # Add one or more users to this segment.
    #
    # Add users in bulk. The response distinguishes successes (added) from
    # failures (couldn't add).
    #
    # Sends a PUT request to +/api/segments/:id/add_users+ (addUsersToSegment).
    #
    # @param params [Hash] request body
    # @option params [Array<Integer>] :user_ids list of user IDs to add
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   segment = client.segments.retrieve(5)
    #   segment.add_users(user_ids: [101, 102, 103])
    # @see https://developers.forem.com/api/v1
    def add_users(params = {}, opts = {})
      request(:put, "#{resource_url}/add_users", params, opts)
    end

    # Remove one or more users from this segment.
    #
    # Sends a PUT request to +/api/segments/:id/remove_users+.
    #
    # @param params [Hash] request body
    # @option params [Array<Integer>] :user_ids list of user IDs to remove
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   segment = client.segments.retrieve(5)
    #   segment.remove_users(user_ids: [101, 102])
    # @see https://developers.forem.com/api/v1
    def remove_users(params = {}, opts = {})
      request(:put, "#{resource_url}/remove_users", params, opts)
    end
  end
end
