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
  # == List Parameters
  #
  # Comments must be filtered by either article or podcast episode:
  # - +a_id+ (String) — Article identifier (required if +p_id+ not provided)
  # - +p_id+ (String) — Podcast Episode identifier (required if +a_id+ not provided)
  # - +page+ (Integer) — Page number
  # - +per_page+ (Integer) — Items per page (default: 50)
  #
  # Returns threaded conversations with nested replies.
  #
  # @example List all comments for an article
  #   comments = client.comments.list(a_id: "some-article-id")
  #   comments.data.each { |c| puts c.body_html }
  #
  # @example List comments for a podcast episode
  #   comments = client.comments.list(p_id: "some-podcast-id")
  #   comments.data.each { |c| puts c.body_html }
  #
  # @example Retrieve a comment tree by root comment ID
  #   comment = client.comments.retrieve("abc123")
  #   puts comment.body_html
  #
  # @see https://developers.forem.com/api/v1#/operations/getCommentsByArticleId
  # @see https://developers.forem.com/api/v1#/operations/getCommentById
  class Comment < APIResource
    extend APIOperations::List
    extend APIOperations::Retrieve

    OBJECT_NAME = "comment"
    RESOURCE_PATH = "/api/comments"
  end
end
