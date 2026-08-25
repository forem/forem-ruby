module Forem
  module Services
    # Service for interacting with the Forem Events API.
    #
    # Events represent live streams, hackathons, takeovers, or community
    # meetups. Access via {Client#events}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   events = client.events.list(type_of: "challenge")
    #   event  = client.events.retrieve(10)
    #
    # @see Event
    # @see https://developers.forem.com/api/v1
    class EventService < BaseService
      # List all events.
      #
      # @param params [Hash] query parameters
      # @option params [String] :type_of filter by event type (e.g. "live_stream", "takeover", "other", "challenge")
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Forem::ListObject<Event>] list of events
      #
      # @example
      #   client.events.list
      #   client.events.list(type_of: "challenge")
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        Event.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single event by its numeric ID or slug.
      #
      # @param id [Integer, String] the event ID or slug
      # @param opts [Hash] per-request options
      # @return [Event] the event with the given ID
      #
      # @example
      #   client.events.retrieve(10)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, opts = {})
        Event.retrieve(id, opts_with_requestor(opts))
      end

      # Create a new event or upsert by matching slugs / ID.
      #
      # Accepts flat attribute hashes or nested under +:event+.
      #
      # @param params [Hash] event attributes
      # @option params [String] :title event title (required)
      # @option params [String] :event_name_slug lowercase slug identifier (required)
      # @option params [String] :event_variation_slug edition/season/year slug (required)
      # @option params [String] :start_time ISO 8601 start timestamp (required)
      # @option params [String] :end_time ISO 8601 end timestamp (required)
      # @option params [String] :type_of event type ("live_stream", "takeover", "other", "challenge")
      # @option params [String] :description Markdown or plain text description
      # @option params [String] :full_details comprehensive plain text / Markdown details dump
      # @option params [String] :primary_stream_url streaming URL
      # @option params [Boolean] :published whether the event is publicly listed
      # @option params [String] :bg_color_hex hex background color code
      # @option params [String] :remote_cover_image_url remote URL to fetch cover image
      # @option params [Integer] :organization_id host organization ID
      # @option params [String] :tag_list comma-separated tags
      # @option params [Hash] :data structured metadata
      # @param opts [Hash] per-request options
      # @return [Event] the newly created event
      #
      # @example
      #   client.events.create(
      #     title: "Hackathon 2026",
      #     event_name_slug: "hackathon",
      #     event_variation_slug: "2026",
      #     start_time: "2026-09-01T09:00:00Z",
      #     end_time: "2026-09-03T18:00:00Z",
      #     type_of: "challenge",
      #     full_details: "Complete schedule and prize information for agent context",
      #     published: true
      #   )
      #
      # @see https://developers.forem.com/api/v1
      def create(params = {}, opts = {})
        Event.create(params, opts_with_requestor(opts))
      end

      # Update an existing event.
      #
      # Accepts flat attribute hashes or nested under +:event+.
      #
      # @param id [Integer, String] the event ID to update
      # @param params [Hash] event attributes to change
      # @param opts [Hash] per-request options
      # @return [Event] the updated event
      #
      # @example
      #   client.events.update(10, title: "Updated Hackathon 2026")
      #
      # @see https://developers.forem.com/api/v1
      def update(id, params = {}, opts = {})
        Event.update(id, params, opts_with_requestor(opts))
      end

      # Delete an event.
      #
      # @param id [Integer, String] the event ID to delete
      # @param opts [Hash] per-request options
      # @return [nil] returns nil on success
      #
      # @example
      #   client.events.delete(10)
      #
      # @see https://developers.forem.com/api/v1
      def delete(id, opts = {})
        Event.delete(id, opts_with_requestor(opts))
      end
    end
  end
end
