module Forem
  class PodcastEpisode < APIResource
    extend APIOperations::List
    OBJECT_NAME = "podcast_episode"
    RESOURCE_PATH = "/api/podcast_episodes"
  end
end
