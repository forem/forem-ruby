module Forem
  module Services
    # Service for interacting with the Forem Videos API.
    #
    # Lists articles that contain video content.
    # Access via {Client#videos}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   videos = client.videos.list(page: 1)
    #
    # @see Video
    # @see https://developers.forem.com/api/v1#tag/videos
    class VideoService < BaseService
      # List articles that contain videos.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Array<Video>] list of articles with video content
      #
      # @example
      #   client.videos.list(page: 2)
      #
      # @see https://developers.forem.com/api/v1#tag/videos/operation/getArticlesWithVideo
      def list(params = {}, opts = {})
        Video.list(params, opts_with_requestor(opts))
      end
    end
  end
end
