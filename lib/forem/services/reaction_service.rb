module Forem
  module Services
    # Service for interacting with the Forem Reactions API.
    #
    # Reactions are emoji-based responses to articles, comments, and other
    # reactable content (likes, unicorns, bookmarks, etc.).
    # Access via {Client#reactions}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   client.reactions.create(reactable_type: "Article", reactable_id: 1, category: "like")
    #   client.reactions.toggle(reactable_type: "Article", reactable_id: 1, category: "unicorn")
    #
    # @see Reaction
    # @see https://developers.forem.com/api/v1
    class ReactionService < BaseService
      # Create a reaction on a reactable resource.
      #
      # @param params [Hash] reaction attributes
      # @option params [String] :reactable_type the type of content to react to
      #   ("Article", "Comment", or "User")
      # @option params [Integer] :reactable_id the ID of the content to react to
      # @option params [String] :category the reaction type ("like", "unicorn",
      #   "exploding_head", "raised_hands", "fire", "thumbsdown", "vomit",
      #   "readinglist")
      # @param opts [Hash] per-request options
      # @return [Reaction] the newly created reaction
      #
      # @example
      #   client.reactions.create(
      #     reactable_type: "Article",
      #     reactable_id: 12345,
      #     category: "unicorn"
      #   )
      #
      # @see https://developers.forem.com/api/v1
      def create(params = {}, opts = {})
        Reaction.create(params, opts_with_requestor(opts))
      end

      # Toggle a reaction on a reactable resource.
      #
      # If the reaction already exists for the authenticated user it will be
      # destroyed; otherwise a new reaction will be created.
      #
      # @param params [Hash] reaction attributes
      # @option params [String] :reactable_type the type of content
      #   ("Article", "Comment", or "User")
      # @option params [Integer] :reactable_id the ID of the content
      # @option params [String] :category the reaction type ("like", "unicorn",
      #   "exploding_head", "raised_hands", "fire", "thumbsdown", "vomit",
      #   "readinglist")
      # @param opts [Hash] per-request options
      # @return [Hash] a hash with a +:result+ key indicating "create" or
      #   "destroy"
      #
      # @example
      #   result = client.reactions.toggle(
      #     reactable_type: "Article",
      #     reactable_id: 12345,
      #     category: "like"
      #   )
      #   puts result.result  # => "create" or "destroy"
      #
      # @see https://developers.forem.com/api/v1
      def toggle(params = {}, opts = {})
        Reaction.toggle(params, opts_with_requestor(opts))
      end
    end
  end
end
