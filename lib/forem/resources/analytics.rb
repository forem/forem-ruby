module Forem
  class Analytics < APIResource
    OBJECT_NAME = "analytics"
    RESOURCE_PATH = "/api/analytics"

    def self.totals(params = {}, opts = {})
      resp = request(:get, "/api/analytics/totals", params, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end

    def self.historical(params = {}, opts = {})
      resp = request(:get, "/api/analytics/historical", params, opts)
      (resp.parsed_body || []).map { |item| Forem::ForemObject.construct_from(item) }
    end

    def self.past_day(params = {}, opts = {})
      resp = request(:get, "/api/analytics/past_day", params, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end

    def self.referrers(params = {}, opts = {})
      resp = request(:get, "/api/analytics/referrers", params, opts)
      (resp.parsed_body || []).map { |item| Forem::ForemObject.construct_from(item) }
    end
  end
end
