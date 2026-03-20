module Forem
  module Services
    # Service for interacting with the Forem Analytics API.
    #
    # Provides engagement and traffic data for articles and organizations.
    # Access via {Client#analytics}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   totals = client.analytics.totals(username: "jsmith")
    #   daily  = client.analytics.historical(username: "jsmith", start: "2024-01-01")
    #
    # @see Analytics
    # @see https://developers.forem.com/api/v1
    class AnalyticsService < BaseService
      # Retrieve total engagement metrics for a user or organization.
      #
      # Returns all-time totals for page views, reactions, comments, and
      # follows.
      #
      # @param params [Hash] query parameters
      # @option params [String] :username filter metrics by author username
      # @option params [String] :organization_id filter metrics by organization
      #   ID
      # @param opts [Hash] per-request options
      # @return [Analytics] total engagement metrics
      #
      # @example
      #   client.analytics.totals(username: "jsmith")
      #
      # @see https://developers.forem.com/api/v1
      def totals(params = {}, opts = {})
        Analytics.totals(params, opts_with_requestor(opts))
      end

      # Retrieve historical engagement metrics broken down by day.
      #
      # @param params [Hash] query parameters
      # @option params [String] :username filter by author username
      # @option params [String] :organization_id filter by organization ID
      # @option params [String] :start start date in ISO 8601 format
      #   (e.g. "2024-01-01")
      # @option params [String] :end end date in ISO 8601 format
      # @param opts [Hash] per-request options
      # @return [Array<Analytics>] daily breakdown of engagement metrics
      #
      # @example
      #   client.analytics.historical(
      #     username: "jsmith",
      #     start: "2024-01-01",
      #     end: "2024-03-31"
      #   )
      #
      # @see https://developers.forem.com/api/v1
      def historical(params = {}, opts = {})
        Analytics.historical(params, opts_with_requestor(opts))
      end

      # Retrieve engagement metrics for the past 24 hours.
      #
      # @param params [Hash] query parameters
      # @option params [String] :username filter by author username
      # @option params [String] :organization_id filter by organization ID
      # @param opts [Hash] per-request options
      # @return [Analytics] metrics for the past day
      #
      # @example
      #   client.analytics.past_day(username: "jsmith")
      #
      # @see https://developers.forem.com/api/v1
      def past_day(params = {}, opts = {})
        Analytics.past_day(params, opts_with_requestor(opts))
      end

      # Retrieve referrer traffic data for a user or organization's content.
      #
      # @param params [Hash] query parameters
      # @option params [String] :username filter by author username
      # @option params [String] :organization_id filter by organization ID
      # @param opts [Hash] per-request options
      # @return [Array<Analytics>] referrer breakdown showing traffic sources
      #
      # @example
      #   client.analytics.referrers(username: "jsmith")
      #
      # @see https://developers.forem.com/api/v1
      def referrers(params = {}, opts = {})
        Analytics.referrers(params, opts_with_requestor(opts))
      end
    end
  end
end
