module Forem
  # Represents an item saved to the authenticated user's reading list.
  #
  # When a user bookmarks an article on Forem, it appears in their reading
  # list. This resource supports listing those saved articles with optional
  # filtering by status.
  #
  # Available operations (via mixins):
  #   - +List+ — GET /api/readinglist
  #
  # @example List all bookmarked articles
  #   items = Forem::ReadingList.list
  #   items.data.each { |item| puts item.article.title }
  #
  # @example List only confirmed (active) reading list items
  #   items = Forem::ReadingList.list(status: "confirmed")
  #   items.data.each { |item| puts item.article.title }
  #
  # @see https://developers.forem.com/api/v1
  class ReadingList < APIResource
    extend APIOperations::List

    OBJECT_NAME = "reading_list"
    RESOURCE_PATH = "/api/readinglist"
  end
end
