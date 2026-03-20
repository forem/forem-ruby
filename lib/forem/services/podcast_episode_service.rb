module Forem
  module Services
    class PodcastEpisodeService < BaseService
      def list(params = {}, opts = {})
        PodcastEpisode.list(params, opts_with_requestor(opts))
      end
    end
  end
end
