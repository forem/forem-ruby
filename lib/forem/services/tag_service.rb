module Forem
  module Services
    # Service for interacting with the Forem Tags API.
    #
    # Access via {Client#tags}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   tags = client.tags.list(per_page: 50)
    #
    # @see Tag
    # @see https://developers.forem.com/api/v1#/operations/getTags
    class TagService < BaseService
      # List tags used on the Forem instance, ordered by popularity.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page (max: 1000)
      # @option params [String] :name exact tag name lookup (returns tag whether or not supported)
      # @param opts [Hash] per-request options
      # @return [ListObject<Tag>] list of tags ordered by article count
      def list(params = {}, opts = {})
        Tag.list(params, opts_with_requestor(opts))
      end

      # List all supported tags in the current subforem (unpaginated).
      #
      # @param params [Hash] optional query parameters
      # @param opts [Hash] per-request options
      # @return [Array<Tag>] supported tags
      def supported(params = {}, opts = {})
        Tag.supported(params, opts_with_requestor(opts))
      end

      # Create a new tag (admin only).
      #
      # @param params [Hash] tag attributes (+:name+, +:pretty_name+,
      #   +:short_summary+, +:wiki_body_markdown+, +:supported+,
      #   +:bg_color_hex+, +:text_color_hex+, +:context_note_instructions+)
      # @param opts [Hash] per-request options
      # @return [Tag] the newly created tag
      def create(params = {}, opts = {})
        Tag.create(params, opts_with_requestor(opts))
      end

      # Update an existing tag (admin only).
      #
      # @param id [Integer, String] the tag ID
      # @param params [Hash] tag attributes to update
      # @param opts [Hash] per-request options
      # @return [Tag] the updated tag
      def update(id, params = {}, opts = {})
        Tag.update(id, params, opts_with_requestor(opts))
      end

      # Add a moderator to a tag (admin only).
      #
      # @param id [Integer, String] the tag ID
      # @param params [Hash] moderator identifier (+:user_id+ or +:username+)
      # @param opts [Hash] per-request options
      # @return [ForemObject] moderator assignment
      def add_moderator(id, params = {}, opts = {})
        Tag.add_moderator(id, params, opts_with_requestor(opts))
      end

      # Remove a moderator from a tag (admin only).
      #
      # @param id [Integer, String] the tag ID
      # @param params [Hash] moderator identifier (+:user_id+ or +:username+)
      # @param opts [Hash] per-request options
      # @return [ForemObject] removed moderator assignment
      def remove_moderator(id, params = {}, opts = {})
        Tag.remove_moderator(id, params, opts_with_requestor(opts))
      end
    end
  end
end
