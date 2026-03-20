module Forem
  class HealthCheck < APIResource
    OBJECT_NAME = "health_check"
    RESOURCE_PATH = "/api/health_checks"

    def self.app(opts = {})
      resp = request(:get, "/api/health_checks/app", {}, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end

    def self.database(opts = {})
      resp = request(:get, "/api/health_checks/database", {}, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end

    def self.cache(opts = {})
      resp = request(:get, "/api/health_checks/cache", {}, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end
  end
end
