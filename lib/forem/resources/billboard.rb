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
