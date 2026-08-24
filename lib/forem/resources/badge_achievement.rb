module Forem
  # Represents a badge awarded to a specific user.
  #
  # Creating a badge achievement awards a badge; deleting one revokes it. There
  # is no update endpoint.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/badge_achievements
  #   - +Create+   — POST /api/badge_achievements
  #   - +Retrieve+ — GET /api/badge_achievements/:id
  #   - +Delete+   — class- and instance-level delete (DELETE /api/badge_achievements/:id)
  #
  # == BadgeAchievement Fields
  #
  # - +id+ (Integer) — Assigned by the API; not writable
  # - +user_id+ (Integer) — The user the badge was awarded to
  # - +badge_id+ (Integer) — The badge that was awarded
  # - +rewarder_id+ (Integer) — The awarding user; not writable, so always
  #   +null+ on achievements created through the API
  # - +rewarding_context_message_markdown+ (String) — Message shown with the award, in markdown
  # - +rewarding_context_message+ (String) — Rendered from
  #   +rewarding_context_message_markdown+ by the API; not writable
  # - +include_default_description+ (Boolean) — Whether the badge description accompanies the message
  # - +metadata+ (ForemObject) — Arbitrary key/value data supplied for context. Defaults to +{}+.
  # - +created_at+ / +updated_at+ (String) — ISO 8601 timestamps; not writable
  #
  # == Authentication
  #
  # All badge achievement endpoints require an admin API key, reads included.
  #
  # == Pagination
  #
  # +list+ returns a fixed 50 records per page.
  #
  # @example Award a badge
  #   achievement = client.badge_achievements.create(
  #     user_id: 123,
  #     badge_id: 45
  #   )
  #   puts achievement.id
  #
  # @example Award a badge with caller-supplied metadata
  #   client.badge_achievements.create(
  #     user_id: 123,
  #     badge_id: 45,
  #     metadata: { entitlement_id: "01a0…", source: "core" }
  #   )
  #
  # @example Revoke a badge
  #   client.badge_achievements.delete(9876)
  #
  # @see Badge
  # @see https://developers.forem.com/api/v1
  class BadgeAchievement < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    include APIOperations::Delete

    OBJECT_NAME = "badge_achievement"
    RESOURCE_PATH = "/api/badge_achievements"
  end
end
