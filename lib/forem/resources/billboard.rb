module Forem
  # Represents a Forem billboard (display advertisement).
  #
  # Billboards are configurable ad units shown to readers on a Forem instance.
  # They support full CRUD operations plus an +unpublish+ action that reverts
  # a live billboard back to draft status. Managing billboards requires an
  # admin API key.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/billboards
  #   - +Create+   — POST /api/billboards
  #   - +Retrieve+ — GET /api/billboards/:id
  #   - +Update+   — PUT /api/billboards/:id
  #   - +Save+     — instance-level save (create or update)
  #
  # == Billboard Fields
  #
  # - +name+ (String) — Internal name to distinguish ads
  # - +body_markdown+ (String, required) — The ad content in markdown
  # - +approved+ (Boolean) — Must be both published AND approved to appear in rotation
  # - +published+ (Boolean) — Must be both published AND approved to appear in rotation
  # - +expires_at+ (String) — ISO 8601 timestamp; automatically unapproved after this time
  # - +placement_area+ (String) — Which area of the site layout the ad appears in
  # - +tag_list+ (String) — Tags on which the ad can display (blank = all tags)
  # - +exclude_article_ids+ (String) — Comma-separated Article IDs where ad should NOT appear
  # - +audience_segment_id+ (Integer) — Target a specific audience segment
  # - +audience_segment_type+ (String) — Must match +audience_segment_id+ if both provided
  # - +target_geolocations+ (Array) — ISO 3166-2 country/region codes (blank = all locations)
  # - +display_to+ (String) — Limits which visitors see the ad
  # - +type_of+ (String) — One of: +"in_house"+ (admin-created), +"community"+ (entity content), +"external"+ (everywhere)
  #
  # @example List all billboards
  #   billboards = Forem::Billboard.list
  #   billboards.data.each { |b| puts "#{b.id}: #{b.name}" }
  #
  # @example Create a billboard
  #   billboard = Forem::Billboard.create(
  #     billboard: {
  #       name: "Summer Sale",
  #       body_markdown: "**50% off** all plans!",
  #       placement_area: "sidebar_left"
  #     }
  #   )
  #
  # @example Retrieve a billboard by ID
  #   billboard = Forem::Billboard.retrieve(7)
  #   puts billboard.name
  #
  # @see https://developers.forem.com/api/v1
  class Billboard < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Save

    OBJECT_NAME = "billboard"
    RESOURCE_PATH = "/api/billboards"

    # Unpublish this billboard, reverting it to draft/inactive status.
    #
    # Marks the billboard as unpublished. A billboard must be both published
    # AND approved to appear in rotation.
    #
    # Sends a PUT request to +/api/billboards/:id/unpublish+.
    # Requires admin privileges.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [ForemResponse] the raw API response
    # @example
    #   billboard = Forem::Billboard.retrieve(7)
    #   billboard.unpublish
    # @see https://developers.forem.com/api/v1
    def unpublish(opts = {})
      request(:put, "#{resource_url}/unpublish", {}, opts)
    end
  end
end
