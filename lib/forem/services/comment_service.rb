module Forem
  module Services
    # Service for interacting with the Forem Comments API.
    #
    # Access via {Client#comments}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   comments = client.comments.list(a_id: 12345)
    #   comment  = client.comments.retrieve("abc123")
    #
    # @see Comment
    # @see https://developers.forem.com/api/v1#tag/comments
    class CommentService < BaseService
      # List comments for an article or podcast episode.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :a_id article ID to fetch comments for
      # @option params [Integer] :p_id podcast episode ID to fetch comments for
      # @param opts [Hash] per-request options
      # @return [Array<Comment>] top-level comments (with nested replies)
      #
      # @example Fetch comments for an article
      #   client.comments.list(a_id: 12345)
      #
      # @example Fetch comments for a podcast episode
      #   client.comments.list(p_id: 67)
      #
      # @see https://developers.forem.com/api/v1#tag/comments/operation/getCommentsByArticleId
      def list(params = {}, opts = {})
        Comment.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single comment by its ID.
      #
      # @param id [String] the comment ID (alphanumeric string as returned by
      #   the API)
      # @param opts [Hash] per-request options
      # @return [Comment] the comment with the given ID
      #
      # @example
      #   client.comments.retrieve("abc123")
      #
      # @see https://developers.forem.com/api/v1#tag/comments/operation/getCommentById
      def retrieve(id, opts = {})
        Comment.retrieve(id, opts_with_requestor(opts))
      end
    end
  end
end
