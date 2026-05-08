module Forem
  module Services
    # Service for interacting with the Forem Segments API.
    #
    # Segments are user-defined audience groups used for targeted content
    # and billboard campaigns.
    # Access via {Client#segments}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   segments = client.segments.list
    #   segment  = client.segments.retrieve(5)
    #
    # @see Segment
    # @see https://developers.forem.com/api/v1#/operations/getSegments
    class SegmentService < BaseService
      # List all audience segments.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Forem::ListObject<Forem::Segment>] paginated list of segments
      #
      # @example
      #   client.segments.list
      #
      # @see https://developers.forem.com/api/v1#/operations/getSegments
      def list(params = {}, opts = {})
        Segment.list(params, opts_with_requestor(opts))
      end

      # Create a new audience segment.
      #
      # The Forem API does not accept any parameters on this endpoint —
      # newly-created segments are always +type_of: "manual"+ and do not
      # carry a name. Manage membership separately via {Segment#add_users}
      # and {Segment#remove_users}.
      #
      # @param params [Hash] ignored by the API, kept for forward-compat
      # @param opts [Hash] per-request options
      # @return [Forem::Segment] the newly created (empty) segment
      #
      # @example
      #   segment = client.segments.create
      #   segment.add_users(user_ids: [101, 102])
      #
      # @see https://developers.forem.com/api/v1#/operations/createSegment
      def create(params = {}, opts = {})
        Segment.create(params, opts_with_requestor(opts))
      end

      # Retrieve a single audience segment by its numeric ID.
      #
      # @param id [Integer, String] the segment ID
      # @param opts [Hash] per-request options
      # @return [Segment] the segment with the given ID
      #
      # @example
      #   client.segments.retrieve(5)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, opts = {})
        Segment.retrieve(id, opts_with_requestor(opts))
      end

      # Delete an audience segment.
      #
      # @param id [Integer, String] the segment ID to delete
      # @param opts [Hash] per-request options
      # @return [nil] returns nil on success
      #
      # @example
      #   client.segments.delete(5)
      #
      # @see https://developers.forem.com/api/v1
      def delete(id, opts = {})
        Segment.delete(id, opts_with_requestor(opts))
      end
    end
  end
end
