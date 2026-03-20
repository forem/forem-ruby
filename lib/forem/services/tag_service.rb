module Forem
  module Services
    # Service for interacting with the Forem Tags API.
    #
    # Access via {Client#tags}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   tags = client.tags.list(per_page: 50)
    #
    # @see Tag
    # @see https://developers.forem.com/api/v1#/operations/getTags
    class TagService < BaseService
      # List tags used on the Forem instance, ordered by popularity.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @param opts [Hash] per-request options
      # @return [Array<Tag>] list of tags ordered by article count
      #
      # @example
      #   client.tags.list(per_page: 100)
      #
      # @see https://developers.forem.com/api/v1#/operations/getTags
      def list(params = {}, opts = {})
        Tag.list(params, opts_with_requestor(opts))
      end
    end
  end
end
