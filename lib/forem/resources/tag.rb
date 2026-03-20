module Forem
  # Represents a Forem tag used to categorize articles.
  #
  # Tags are keywords attached to articles that help readers discover related
  # content. Only listing is supported through the public API; tags are created
  # implicitly when articles are published with new tag names.
  #
  # Tags are ordered by popularity. Default: 10 per page.
  #
  # Available operations (via mixins):
  #   - +List+ — GET /api/tags
  #
  # @example List tags ordered by popularity
  #   tags = Forem::Tag.list(per_page: 50)
  #   tags.data.each { |t| puts "#{t.name} (#{t.points} points)" }
  #
  # @example Iterate over every tag using auto-pagination
  #   Forem::Tag.list.auto_paging_each { |t| puts t.name }
  #
  # @see https://developers.forem.com/api/v1#/operations/getTags
  class Tag < APIResource
    extend APIOperations::List

    OBJECT_NAME = "tag"
    RESOURCE_PATH = "/api/tags"
  end
end
