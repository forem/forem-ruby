module Forem
  # Represents a badge that can be awarded to users on a Forem instance.
  #
  # Badges are awards that can be given to users. Badges support full CRUD
  # operations.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/badges
  #   - +Create+   — POST /api/badges
  #   - +Retrieve+ — GET /api/badges/:id
  #   - +Update+   — PUT /api/badges/:id
  #   - +Delete+   — class- and instance-level delete (DELETE /api/badges/:id)
  #   - +Save+     — instance-level save (create or update)
  #
  # == Badge Fields
  #
  # - +id+ (Integer) — Assigned by the API; not writable
  # - +title+ (String) — Badge title; unique across the instance
  # - +slug+ (String) — Generated from +title+ by the API; not writable
  # - +description+ (String) — Badge description
  # - +badge_image+ (String) — Badge image URL; set on write with
  #   +remote_badge_image_url+
  # - +credits_awarded+ (Integer) — Credits granted alongside the badge
  # - +allow_multiple_awards+ (Boolean) — Whether the badge can be awarded to the same user more than once
  # - +created_at+ / +updated_at+ (String) — ISO 8601 timestamps; not writable
  #
  # == Authentication
  #
  # All badge endpoints require an admin API key, reads included.
  #
  # == Pagination
  #
  # +list+ returns a fixed 50 records per page.
  #
  # @example List every badge
  #   page = 1
  #   loop do
  #     badges = client.badges.list(page: page)
  #     break if badges.data.empty?
  #     badges.data.each { |b| puts "#{b.id}: #{b.title}" }
  #     page += 1
  #   end
  #
  # @example Retrieve a badge by ID
  #   badge = client.badges.retrieve(45)
  #   puts badge.title
  #
  # @see BadgeAchievement
  # @see https://developers.forem.com/api/v1
  class Badge < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Delete
    include APIOperations::Save

    OBJECT_NAME = "badge"
    RESOURCE_PATH = "/api/badges"
  end
end
