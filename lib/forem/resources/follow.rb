module Forem
  # Represents a tag-follow relationship for the authenticated user.
  #
  # A Follow records that the authenticated user is following a particular tag.
  # The list endpoint returns all tags the current user follows. The create
  # endpoint lets the user follow one or more tags in a single request.
  #
  # Note: unlike most resources, the list endpoint hits +/api/follows/tags+
  # rather than +/api/follows+.
  #
  # @example List tags the authenticated user is following
  #   follows = Forem::Follow.list
  #   follows.data.each { |f| puts f.name }
  #
  # @example Follow a set of tags
  #   Forem::Follow.create(
  #     follows: [{ id: 1 }, { id: 2 }]
  #   )
  #
  # @see https://developers.forem.com/api/v1
  class Follow < APIResource
    OBJECT_NAME = "follow"
    RESOURCE_PATH = "/api/follows"

    # Return a paginated list of tags followed by the authenticated user.
    #
    # Sends a GET request to +/api/follows/tags+.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ListObject<Forem::Follow>] paginated list of followed tags
    # @example
    #   follows = Forem::Follow.list(per_page: 10)
    #   follows.data.each { |f| puts f.name }
    # @see https://developers.forem.com/api/v1
    def self.list(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "/api/follows/tags", params, opts)
      data = (resp.parsed_body || []).map { |item| construct_from(item) }
      per_page = params[:per_page] || params["per_page"] || 30
      page = params[:page] || params["page"] || 1
      ListObject.new(
        data: data, current_page: page.to_i, per_page: per_page.to_i,
        resource_class: self,
        filters: params.reject { |k, _| [:page, :per_page, "page", "per_page"].include?(k) },
        requestor: requestor
      )
    end

    # Follow one or more tags on behalf of the authenticated user.
    #
    # Sends a POST request to +/api/follows+.
    #
    # @param params [Hash] request body
    # @option params [Array<Hash>] :follows array of tag objects, each containing an +:id+ key
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::Follow] the created follow object returned by the API
    # @example
    #   Forem::Follow.create(follows: [{ id: 5 }, { id: 12 }])
    # @see https://developers.forem.com/api/v1
    def self.create(params = {}, opts = {})
      resp = request(:post, resource_path, params, opts)
      construct_from(resp.parsed_body)
    end
  end
end
