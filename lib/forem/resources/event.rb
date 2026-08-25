module Forem
  # Represents an event on a Forem instance.
  #
  # Events can represent live streams, hackathons, takeovers, or community
  # meetups. The API supports full CRUD operations, and the create endpoint
  # behaves as an idempotent upsert when matching slugs or numeric IDs are
  # provided.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/events (supports +type_of+ filtering)
  #   - +Create+   — POST /api/events (idempotent upsert, admin privileges)
  #   - +Retrieve+ — GET /api/events/:id_or_slug
  #   - +Update+   — PUT /api/events/:id_or_slug (admin privileges)
  #   - +Delete+   — class- and instance-level delete (DELETE /api/events/:id_or_slug, admin privileges)
  #   - +Save+     — instance-level save (create or update)
  #
  # == List Parameters
  #
  # When calling +Event.list+, the following query parameters are supported:
  #
  # - +type_of+ (String) — Filter by event type: +"live_stream"+, +"takeover"+, +"other"+, +"challenge"+
  # - +page+ (Integer) — Page number (default: 1)
  # - +per_page+ (Integer) — Items per page (default: 30, max: 1000)
  #
  # == Event Fields
  #
  # - +id+ (Integer) — Assigned by the API
  # - +title+ (String, required) — Title of the event
  # - +event_name_slug+ (String, required) — Lowercase slug identifier (e.g. +"hackrice"+)
  # - +event_variation_slug+ (String, required) — Edition/season/year slug (e.g. +"13"+ or +"2026"+)
  # - +description+ (String) — Markdown or plain text description
  # - +full_details+ (String) — Comprehensive plain text / Markdown dump of all event details, agenda, and context notes
  # - +start_time+ (String / ISO 8601, required) — Start timestamp
  # - +end_time+ (String / ISO 8601, required) — End timestamp
  # - +type_of+ (String) — One of: +"live_stream"+, +"takeover"+, +"other"+, +"challenge"+
  # - +broadcast_config+ (String) — One of: +"no_broadcast"+, +"tagged_broadcast"+, +"global_broadcast"+
  # - +primary_stream_url+ (String) — Video streaming URL (YouTube, Twitch, Streamyard)
  # - +manual_broadcast_end+ (Boolean) — Whether broadcasting end is manually handled
  # - +published+ (Boolean) — Whether the event is publicly listed
  # - +elevated+ (Boolean) — Whether the event is featured/elevated
  # - +bg_color_hex+ (String) — 6-digit hex background color code (e.g. +"#7C3AED"+)
  # - +cover_image+ (String) — Uploaded cover image filename
  # - +remote_cover_image_url+ (String) — Remote URL to fetch, crop, and store as cover image
  # - +remove_cover_image+ (Boolean) — Flag to delete the existing cover image
  # - +tag_list+ (String) — Comma-separated list of tags
  # - +user_id+ (Integer) — ID of the host/creator user
  # - +organization_id+ (Integer) — ID of the host organization
  # - +page_id+ (Integer) — ID of an associated page
  # - +delegate_to_page+ (Boolean) — Whether landing page links delegate directly to page
  # - +data+ (Hash) — Structured metadata such as +location+, +format+, +external_registration_url+
  # - +cover_image_url+ (String) — Public URL to the uploaded cover image
  # - +social_image_url+ (String) — Public URL to the 1200x630 social card crop or default fallback
  # - +background_hex_color+ (String) — Effective background hex color
  # - +formatted_date_range+ (String) — Display-ready date range string (e.g. +"AUG 28 - 30"+)
  # - +location+ (String) — Display location string (e.g. +"Everywhere, Worldwide"+)
  # - +format+ (String) — Display format pill label (e.g. +"DIGITAL"+, +"IN-PERSON"+)
  #
  # @example List published events or filter by type_of
  #   events = client.events.list(type_of: "challenge")
  #   events.each { |e| puts "#{e.title} (#{e.formatted_date_range})" }
  #
  # @example Retrieve an event by numeric ID or slug
  #   event = client.events.retrieve(12)
  #   puts event.title
  #
  # @example Create or upsert an event
  #   event = client.events.create(
  #     title: "HackRice XIII",
  #     event_name_slug: "hackrice",
  #     event_variation_slug: "13",
  #     start_time: "2026-09-11T10:00:00Z",
  #     end_time: "2026-09-13T16:00:00Z",
  #     type_of: "challenge",
  #     full_details: "Full hackathon schedule, judging rubric, and prizes breakdown.",
  #     published: true,
  #     bg_color_hex: "#7C3AED",
  #     remote_cover_image_url: "https://assets.example.com/banner.png",
  #     data: {
  #       location: "Houston, Texas, US",
  #       format: "IN-PERSON",
  #       external_registration_url: "https://hackrice.com"
  #     }
  #   )
  #
  # @example Delete an event
  #   client.events.delete(12)
  #
  # @see https://developers.forem.com/api/v1
  class Event < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Delete
    include APIOperations::Save

    OBJECT_NAME = "event"
    RESOURCE_PATH = "/api/events"

    # Create a new event or upsert by matching slugs.
    #
    # Automatically wraps flat parameters under the +:event+ key expected by the API.
    #
    # @param params [Hash] event parameters
    # @param opts [Hash] per-request options
    # @return [Event] the newly created event
    def self.create(params = {}, opts = {})
      payload = params.key?(:event) || params.key?("event") ? params : { event: params }
      super(payload, opts)
    end

    # Update an existing event.
    #
    # Automatically wraps flat parameters under the +:event+ key expected by the API.
    #
    # @param id [Integer, String] event ID or slug
    # @param params [Hash] attributes to update
    # @param opts [Hash] per-request options
    # @return [Event] the updated event
    def self.update(id, params = {}, opts = {})
      payload = params.key?(:event) || params.key?("event") ? params : { event: params }
      super(id, payload, opts)
    end

    # Save this event instance via the API.
    #
    # Automatically wraps flat parameters under the +:event+ key expected by the API.
    #
    # @param params [Hash] attributes to update
    # @param opts [Hash] per-request keyword options
    # @return [Event] updated event instance
    def save(params = {}, **opts)
      payload = params.key?(:event) || params.key?("event") ? params : { event: params }
      super(payload, **opts)
    end
  end
end
