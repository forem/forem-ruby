module Forem
  module Services
    # Service for interacting with the Forem Billboard Campaigns API.
    #
    # Access via {Client#billboard_campaigns}.
    #
    # @see BillboardCampaign
    # @see https://developers.forem.com/api/v1
    class BillboardCampaignService < BaseService
      # List billboard campaigns.
      #
      # @param params [Hash] query parameters (+:page+)
      # @param opts [Hash] per-request options
      # @return [ListObject<BillboardCampaign>] paginated list of billboard campaigns
      def list(params = {}, opts = {})
        BillboardCampaign.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single billboard campaign by ID.
      #
      # @param id [Integer, String] the billboard campaign ID
      # @param opts [Hash] per-request options
      # @return [BillboardCampaign] the billboard campaign
      def retrieve(id, opts = {})
        BillboardCampaign.retrieve(id, opts_with_requestor(opts))
      end

      # Create a new billboard campaign.
      #
      # @param params [Hash] campaign attributes (+:name+, +:organization_id+,
      #   +:expires_at+, +:max_impressions_count+, +:max_clicks_count+,
      #   +:ideal_daily_impressions+)
      # @param opts [Hash] per-request options
      # @return [BillboardCampaign] the newly created campaign
      def create(params = {}, opts = {})
        BillboardCampaign.create(params, opts_with_requestor(opts))
      end

      # Update an existing billboard campaign.
      #
      # @param id [Integer, String] the billboard campaign ID
      # @param params [Hash] campaign attributes to change
      # @param opts [Hash] per-request options
      # @return [BillboardCampaign] the updated campaign
      def update(id, params = {}, opts = {})
        BillboardCampaign.update(id, params, opts_with_requestor(opts))
      end
    end
  end
end
