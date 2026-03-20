module Forem
  module Services
    # Service for interacting with the Forem Podcast Episodes API.
    #
    # Access via {Client#podcast_episodes}. All methods inject the client's
    # requestor automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   episodes = client.podcast_episodes.list(username: "codenewbies")
    #
    # @see PodcastEpisode
    # @see https://developers.forem.com/api/v1#tag/podcast-episodes
    class PodcastEpisodeService < BaseService
      # List podcast episodes.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @option params [String] :username filter episodes by the podcast owner's
      #   username
      # @param opts [Hash] per-request options
      # @return [Array<PodcastEpisode>] list of podcast episodes
      #
      # @example
      #   client.podcast_episodes.list(username: "codenewbies", per_page: 20)
      #
      # @see https://developers.forem.com/api/v1#tag/podcast-episodes/operation/getPodcastEpisodes
      def list(params = {}, opts = {})
        PodcastEpisode.list(params, opts_with_requestor(opts))
      end
    end
  end
end
