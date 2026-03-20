module Forem
  # Provides access to analytics data for the authenticated user's content.
  #
  # All analytics endpoints require authentication. Returns analytics for
  # articles owned by the authenticated user.
  #
  # The Analytics resource exposes four read-only reporting endpoints:
  # cumulative totals, day-by-day historical data, yesterday's aggregates,
  # and traffic referrer breakdowns. All endpoints require authentication.
  # Organization-level analytics can be accessed by passing an +:org_id+
  # parameter.
  #
  # @example Retrieve lifetime totals
  #   totals = Forem::Analytics.totals
  #   puts "Total reactions: #{totals.reactions}"
  #
  # @example Retrieve historical data for a date range
  #   history = Forem::Analytics.historical(start: "2024-01-01", end: "2024-01-31")
  #   history.each { |day| puts "#{day.date}: #{day.page_views}" }
  #
  # @example Retrieve yesterday's stats for an organization
  #   stats = Forem::Analytics.past_day(org_id: 7)
  #   puts stats.page_views
  #
  # @see https://developers.forem.com/api/v1
  class Analytics < APIResource
    OBJECT_NAME = "analytics"
    RESOURCE_PATH = "/api/analytics"

    # Return cumulative analytics totals for the authenticated user (or org).
    #
    # Sends a GET request to +/api/analytics/totals+.
    #
    # @param params [Hash] query parameters
    # @option params [String] :article_id filter analytics to a specific article
    # @option params [String] :organization_id filter analytics to a specific organization
    # @option params [Integer] :org_id ID of the organization to fetch analytics for
    #   (omit for the authenticated user's personal analytics)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ForemObject] object with cumulative stat fields
    #   (e.g., +reactions+, +comments+, +page_views+)
    # @example
    #   totals = Forem::Analytics.totals
    #   puts totals.page_views
    # @see https://developers.forem.com/api/v1
    def self.totals(params = {}, opts = {})
      resp = request(:get, "/api/analytics/totals", params, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end

    # Return day-by-day historical analytics for a given date range.
    #
    # Sends a GET request to +/api/analytics/historical+.
    #
    # @param params [Hash] query parameters
    # @option params [String] :article_id filter analytics to a specific article
    # @option params [String] :organization_id filter analytics to a specific organization
    # @option params [String] :start start date (ISO 8601)
    # @option params [String] :end end date (ISO 8601)
    # @option params [Integer] :org_id ID of the organization (omit for personal analytics)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::ForemObject>] per-day stat objects covering the requested range
    # @example
    #   history = Forem::Analytics.historical(start: "2024-06-01", end: "2024-06-30")
    #   history.each { |day| puts "#{day.date}: #{day.page_views} views" }
    # @see https://developers.forem.com/api/v1
    def self.historical(params = {}, opts = {})
      resp = request(:get, "/api/analytics/historical", params, opts)
      (resp.parsed_body || []).map { |item| Forem::ForemObject.construct_from(item) }
    end

    # Return aggregated analytics for the previous calendar day.
    #
    # Sends a GET request to +/api/analytics/past_day+.
    #
    # @param params [Hash] query parameters
    # @option params [String] :article_id filter analytics to a specific article
    # @option params [String] :organization_id filter analytics to a specific organization
    # @option params [Integer] :org_id ID of the organization (omit for personal analytics)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ForemObject] stat object for yesterday (page views, reactions, etc.)
    # @example
    #   yesterday = Forem::Analytics.past_day
    #   puts "Yesterday's page views: #{yesterday.page_views}"
    # @see https://developers.forem.com/api/v1
    def self.past_day(params = {}, opts = {})
      resp = request(:get, "/api/analytics/past_day", params, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end

    # Return a breakdown of traffic referrers for the authenticated user's content.
    #
    # Sends a GET request to +/api/analytics/referrers+.
    #
    # @param params [Hash] query parameters
    # @option params [String] :article_id filter analytics to a specific article
    # @option params [String] :organization_id filter analytics to a specific organization
    # @option params [Integer] :org_id ID of the organization (omit for personal analytics)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::ForemObject>] referrer objects each with a +domain+ and +count+ field
    # @example
    #   referrers = Forem::Analytics.referrers
    #   referrers.each { |r| puts "#{r.domain}: #{r.count}" }
    # @see https://developers.forem.com/api/v1
    def self.referrers(params = {}, opts = {})
      resp = request(:get, "/api/analytics/referrers", params, opts)
      (resp.parsed_body || []).map { |item| Forem::ForemObject.construct_from(item) }
    end
  end
end
