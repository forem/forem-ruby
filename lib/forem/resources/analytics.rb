module Forem
  # Provides access to analytics data for the authenticated user's content.
  #
  # All analytics endpoints require authentication. They return analytics for
  # the calling user (or an organization, when +:organization_id+ is passed).
  #
  # The Analytics resource exposes four read-only reporting endpoints:
  # cumulative totals, day-by-day historical data, yesterday's aggregates,
  # and traffic referrer breakdowns.
  #
  # == Response shapes
  #
  # The Forem analytics endpoints don't all return the same kind of object,
  # so this resource preserves each endpoint's natural shape rather than
  # forcing them into a uniform list:
  #
  # * {.totals}     — single nested-stats object
  # * {.historical} — +Hash+ keyed by +"YYYY-MM-DD"+ date string
  # * {.past_day}   — +Hash+ keyed by +"YYYY-MM-DD"+ (typically 1–2 entries)
  # * {.referrers}  — +Array+ of referrer objects (extracted from +domains+)
  #
  # @example Lifetime totals
  #   totals = client.analytics.totals
  #   puts totals.reactions.total   #=> 7
  #   puts totals.page_views.total  #=> 7
  #
  # @example Historical data for a date range
  #   history = client.analytics.historical(start: "2026-04-01", end: "2026-04-30")
  #   history.each do |date, stats|
  #     puts "#{date}: #{stats.page_views.total} views"
  #   end
  #
  # @example Referrer breakdown
  #   client.analytics.referrers.each { |r| puts "#{r.domain}: #{r.count}" }
  #
  # @see https://developers.forem.com/api/v1
  class Analytics < APIResource
    OBJECT_NAME = "analytics"
    RESOURCE_PATH = "/api/analytics"

    # Return cumulative analytics totals for the authenticated user (or org).
    #
    # The response groups totals into nested buckets — +comments+, +follows+,
    # +reactions+, and +page_views+ — each with its own sub-fields. To read
    # a count, navigate one level deeper than you might expect (e.g.
    # +totals.reactions.total+, not +totals.reactions+).
    #
    # @param params [Hash] query parameters
    # @option params [String] :article_id filter to a specific article
    # @option params [Integer] :organization_id ID of the organization
    # @param opts [Hash] per-request options
    # @return [Forem::ForemObject] cumulative stats with nested sub-objects
    # @example
    #   totals = client.analytics.totals
    #   puts totals.reactions.total          #=> 7
    #   puts totals.reactions.like           #=> 2
    #   puts totals.page_views.total         #=> 7
    # @see https://developers.forem.com/api/v1
    def self.totals(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "/api/analytics/totals", params, opts)
      Forem::ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Return day-by-day historical analytics for a given date range.
    #
    # The response is a +Hash+ keyed by the calendar date (+"YYYY-MM-DD"+).
    # Each value is a stats object with the same nested shape as {.totals}.
    #
    # @param params [Hash] query parameters
    # @option params [String] :start (required) start date in YYYY-MM-DD form.
    # @option params [String] :end end date in YYYY-MM-DD form.
    # @option params [String] :article_id filter to a specific article.
    # @option params [Integer] :organization_id ID of the organization.
    # @param opts [Hash] per-request options
    # @return [Hash{String => Forem::ForemObject}] stats keyed by date.
    # @example
    #   history = client.analytics.historical(start: "2026-04-01", end: "2026-04-15")
    #   history.each do |date, stats|
    #     puts "#{date}: #{stats.page_views.total} views"
    #   end
    # @see https://developers.forem.com/api/v1
    def self.historical(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "/api/analytics/historical", params, opts)
      grouped_by_day(resp.parsed_body, requestor)
    end

    # Return aggregated analytics for the previous calendar day(s).
    #
    # The response shape mirrors {.historical}: a +Hash+ keyed by date.
    # Forem typically returns one or two entries (yesterday plus today's
    # partial), so callers usually want either the most recent date or
    # iteration with +#each+.
    #
    # @param params [Hash] query parameters
    # @option params [String] :article_id filter to a specific article.
    # @option params [Integer] :organization_id ID of the organization.
    # @param opts [Hash] per-request options
    # @return [Hash{String => Forem::ForemObject}] stats keyed by date.
    # @example
    #   stats = client.analytics.past_day
    #   latest_date, latest_stats = stats.max_by { |date, _| date }
    #   puts "#{latest_date}: #{latest_stats.page_views.total} views"
    # @see https://developers.forem.com/api/v1
    def self.past_day(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "/api/analytics/past_day", params, opts)
      grouped_by_day(resp.parsed_body, requestor)
    end

    # Return the breakdown of traffic referrers for the authenticated user's
    # content.
    #
    # The endpoint wraps the data in a +{"domains" => [...]}+ envelope. This
    # method unwraps that envelope and returns the inner array directly so
    # callers can iterate without an extra hop.
    #
    # @param params [Hash] query parameters
    # @option params [String] :start start date in YYYY-MM-DD form.
    # @option params [String] :end end date in YYYY-MM-DD form.
    # @option params [String] :article_id filter to a specific article.
    # @option params [Integer] :organization_id ID of the organization.
    # @param opts [Hash] per-request options
    # @return [Array<Forem::ForemObject>] referrer objects with +domain+ and
    #   +count+ fields.
    # @example
    #   client.analytics.referrers.each { |r| puts "#{r.domain}: #{r.count}" }
    # @see https://developers.forem.com/api/v1
    def self.referrers(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "/api/analytics/referrers", params, opts)
      body = resp.parsed_body
      domains = body.is_a?(Hash) ? (body["domains"] || []) : []
      domains.map { |item| Forem::ForemObject.construct_from(item, requestor: requestor) }
    end

    # Internal: convert the date-keyed response of historical/past_day into a
    # Hash<String, ForemObject>. Preserves +nil+ stat values (which the API
    # emits for some days) by converting them to an empty ForemObject.
    #
    # @api private
    def self.grouped_by_day(body, requestor)
      return {} unless body.is_a?(Hash)
      body.each_with_object({}) do |(date, stats), out|
        out[date] = Forem::ForemObject.construct_from(stats || {}, requestor: requestor)
      end
    end
    private_class_method :grouped_by_day
  end
end
