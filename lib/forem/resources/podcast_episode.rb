module Forem
  # Represents a podcast episode published on a Forem instance.
  #
  # Podcast episodes are audio content items associated with a podcast channel.
  # The public API supports listing episodes, optionally filtered by username
  # (the podcast owner) or a specific podcast slug.
  #
  # Available operations (via mixins):
  #   - +List+ — GET /api/podcast_episodes
  #
  # @example List all podcast episodes
  #   episodes = Forem::PodcastEpisode.list(per_page: 30)
  #   episodes.data.each { |ep| puts ep.title }
  #
  # @example List episodes for a specific podcast
  #   episodes = Forem::PodcastEpisode.list(username: "devpodcast")
  #   episodes.data.each { |ep| puts ep.title }
  #
  # @see https://developers.forem.com/api/v1
  class PodcastEpisode < APIResource
    extend APIOperations::List

    OBJECT_NAME = "podcast_episode"
    RESOURCE_PATH = "/api/podcast_episodes"
  end
end
