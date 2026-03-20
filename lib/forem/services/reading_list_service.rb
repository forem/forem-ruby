module Forem
  module Services
    # Service for interacting with the Forem Reading List API.
    #
    # Lists articles the authenticated user has bookmarked for later reading.
    # Access via {Client#reading_list}. All methods inject the client's
    # requestor automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   bookmarks = client.reading_list.list(page: 1, per_page: 20)
    #
    # @see ReadingList
    # @see https://developers.forem.com/api/v1#/operations/getReadinglist
    class ReadingListService < BaseService
      # List articles in the authenticated user's reading list.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @option params [String] :status filter by bookmark status ("valid",
      #   "invalid", "confirmed", "archived")
      # @param opts [Hash] per-request options
      # @return [Array<ReadingList>] bookmarked articles for the current user
      #
      # @example
      #   client.reading_list.list(per_page: 50)
      #
      # @see https://developers.forem.com/api/v1#/operations/getReadinglist
      def list(params = {}, opts = {})
        ReadingList.list(params, opts_with_requestor(opts))
      end
    end
  end
end
