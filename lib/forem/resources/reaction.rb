module Forem
  # Represents a reaction (like, unicorn, exploding head, etc.) on a Forem article or comment.
  #
  # Reactions are emoji-style responses that authenticated users can add to
  # articles or comments. The create endpoint adds a reaction, and the toggle
  # endpoint adds it if it does not exist or removes it if it already does.
  #
  # Available operations (via mixins):
  #   - +Create+ — POST /api/reactions
  #
  # @example Create a reaction on an article
  #   Forem::Reaction.create(
  #     reactable_id: 12345,
  #     reactable_type: "Article",
  #     category: "like"
  #   )
  #
  # @example Toggle a reaction (add if absent, remove if present)
  #   result = Forem::Reaction.toggle(
  #     reactable_id: 12345,
  #     reactable_type: "Article",
  #     category: "unicorn"
  #   )
  #   puts result.result   # => "create" or "destroy"
  #
  # @see https://developers.forem.com/api/v1
  class Reaction < APIResource
    extend APIOperations::Create

    OBJECT_NAME = "reaction"
    RESOURCE_PATH = "/api/reactions"

    # Toggle a reaction on a reactable object.
    #
    # If the authenticated user has not yet reacted with the given category,
    # the reaction is created. If they have already reacted, it is removed.
    # Sends a POST request to +/api/reactions/toggle+.
    #
    # @param params [Hash] request body
    # @option params [Integer] :reactable_id ID of the article or comment to react to
    # @option params [String] :reactable_type the type of the target; one of +"Article"+ or +"Comment"+
    # @option params [String] :category the reaction emoji; one of +"like"+, +"unicorn"+,
    #   +"exploding_head"+, +"raised_hands"+, or +"fire"+
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::Reaction] reaction object with a +result+ field (++"create"++ or ++"destroy"++)
    # @example
    #   result = Forem::Reaction.toggle(
    #     reactable_id: 42,
    #     reactable_type: "Article",
    #     category: "fire"
    #   )
    #   puts result.result   # => "create" or "destroy"
    # @see https://developers.forem.com/api/v1
    def self.toggle(params = {}, opts = {})
      resp = request(:post, "/api/reactions/toggle", params, opts)
      construct_from(resp.parsed_body)
    end
  end
end
