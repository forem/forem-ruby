module Forem
  # Represents an article with an associated video on a Forem instance.
  #
  # Video articles are a special content type where the primary content is a
  # video rather than text. The public API supports listing video articles,
  # returned ordered by publication date.
  #
  # Returns published articles with video, ordered by descending popularity.
  # Default: 24 per page.
  #
  # Available operations (via mixins):
  #   - +List+ — GET /api/videos
  #
  # @example List video articles
  #   videos = Forem::Video.list(per_page: 10)
  #   videos.data.each { |v| puts v.title }
  #
  # @example Iterate over all video articles using auto-pagination
  #   Forem::Video.list.auto_paging_each { |v| puts "#{v.title}: #{v.video_source_url}" }
  #
  # @see https://developers.forem.com/api/v1#/operations/videos
  class Video < APIResource
    extend APIOperations::List

    OBJECT_NAME = "video"
    RESOURCE_PATH = "/api/videos"
  end
end
