module Forem
  # Represents a Forem billboard campaign (shared budget/pacing container for billboards).
  #
  # Requires an admin API key with billboard permissions.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/billboard_campaigns
  #   - +Create+   — POST /api/billboard_campaigns
  #   - +Retrieve+ — GET /api/billboard_campaigns/:id
  #   - +Update+   — PUT /api/billboard_campaigns/:id
  #   - +Save+     — instance-level save (create or update)
  #
  # == BillboardCampaign Fields
  #
  # - +id+ (Integer)
  # - +name+ (String)
  # - +organization_id+ (Integer, nil)
  # - +expires_at+ (String, nil)
  # - +max_impressions_count+ (Integer, nil)
  # - +max_clicks_count+ (Integer, nil)
  # - +ideal_daily_impressions+ (Integer, nil)
  #
  # @example List billboard campaigns
  #   campaigns = client.billboard_campaigns.list
  #   campaigns.each { |c| puts "#{c.id}: #{c.name}" }
  #
  # @example Create a billboard campaign (flat params)
  #   campaign = client.billboard_campaigns.create(
  #     name: "Q4 Launch",
  #     max_impressions_count: 100_000,
  #     ideal_daily_impressions: 5_000
  #   )
  #
  # @see https://developers.forem.com/api/v1
  class BillboardCampaign < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Save

    OBJECT_NAME = "billboard_campaign"
    RESOURCE_PATH = "/api/billboard_campaigns"
  end
end
