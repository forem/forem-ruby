module Forem
  # Represents an item saved to the authenticated user's reading list.
  #
  # When a user bookmarks an article on Forem, it appears in their reading
  # list. This resource supports listing those saved articles with optional
  # filtering by status.
  #
  # Requires authentication. Returns articles saved to the user's reading
  # list. Default: 30 per page.
  #
  # Available operations (via mixins):
  #   - +List+ — GET /api/readinglist
  #
  # @example List all bookmarked articles
  #   items = client.reading_list.list
  #   items.data.each { |item| puts item.article.title }
  #
  # @example List only confirmed (active) reading list items
  #   items = client.reading_list.list(status: "confirmed")
  #   items.data.each { |item| puts item.article.title }
  #
  # @see https://developers.forem.com/api/v1#/operations/getReadinglist
  class ReadingList < APIResource
    extend APIOperations::List

    OBJECT_NAME = "reading_list"
    RESOURCE_PATH = "/api/readinglist"
  end
end
