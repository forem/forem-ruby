module Forem
  # Represents a user who follows the authenticated user.
  #
  # A Follower record describes a user that has subscribed to the
  # authenticated user's content. Only listing is supported — you cannot
  # create or delete follower relationships through this resource directly.
  #
  # Note: the list endpoint hits +/api/followers/users+ (not +/api/followers+),
  # and the default page size is 80 (larger than most other resources).
  #
  # @example List users who follow the authenticated user
  #   followers = Forem::Follower.list
  #   followers.data.each { |f| puts f.name }
  #
  # @example Iterate over all followers using auto-pagination
  #   Forem::Follower.list.auto_paging_each { |f| puts f.username }
  #
  # @see https://developers.forem.com/api/v1
  class Follower < APIResource
    OBJECT_NAME = "follower"
    RESOURCE_PATH = "/api/followers"

    # Return a paginated list of users who follow the authenticated user.
    #
    # Sends a GET request to +/api/followers/users+.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 80)
    # @option params [String] :sort sort order; one of +"created_at"+ or +"name"+
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ListObject<Forem::Follower>] paginated list of followers
    # @example
    #   followers = Forem::Follower.list(per_page: 25, sort: "name")
    #   followers.data.each { |f| puts f.name }
    # @see https://developers.forem.com/api/v1
    def self.list(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "/api/followers/users", params, opts)
      data = (resp.parsed_body || []).map { |item| construct_from(item) }
      per_page = params[:per_page] || params["per_page"] || 80
      page = params[:page] || params["page"] || 1
      ListObject.new(
        data: data, current_page: page.to_i, per_page: per_page.to_i,
        resource_class: self,
        filters: params.reject { |k, _| [:page, :per_page, "page", "per_page"].include?(k) },
        requestor: requestor
      )
    end
  end
end
