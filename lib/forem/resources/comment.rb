module Forem
  # Represents a comment on a Forem article or podcast episode.
  #
  # Comments are threaded replies attached to articles or podcast episodes.
  # They can be listed (optionally filtered by the parent content item) or
  # retrieved individually by ID.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/comments  (pass +:a_id+ or +:p_id+ to filter)
  #   - +Retrieve+ — GET /api/comments/:id  (returns comment tree rooted at that ID)
  #
  # @example List all comments for an article
  #   comments = Forem::Comment.list(a_id: "some-article-id")
  #   comments.data.each { |c| puts c.body_html }
  #
  # @example List comments for a podcast episode
  #   comments = Forem::Comment.list(p_id: "some-podcast-id")
  #   comments.data.each { |c| puts c.body_html }
  #
  # @example Retrieve a comment tree by root comment ID
  #   comment = Forem::Comment.retrieve("abc123")
  #   puts comment.body_html
  #
  # @see https://developers.forem.com/api/v1
  class Comment < APIResource
    extend APIOperations::List
    extend APIOperations::Retrieve

    OBJECT_NAME = "comment"
    RESOURCE_PATH = "/api/comments"
  end
end
