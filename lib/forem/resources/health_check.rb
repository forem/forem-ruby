module Forem
  # Provides access to the health-check endpoints of a Forem instance.
  #
  # Health check endpoints are public and do not require authentication.
  #
  # Health checks let you verify that the various subsystems of a Forem
  # deployment are operational. There are three separate checks: the
  # application server, the database, and the cache layer. These endpoints
  # do not require authentication and return a simple status indicator.
  #
  # @example Check overall application health
  #   status = Forem::HealthCheck.app
  #   puts status.status   # => "OK" when healthy
  #
  # @example Check database connectivity
  #   status = Forem::HealthCheck.database
  #   puts status.status
  #
  # @example Check cache availability
  #   status = Forem::HealthCheck.cache
  #   puts status.status
  #
  # @see https://developers.forem.com/api/v1
  class HealthCheck < APIResource
    OBJECT_NAME = "health_check"
    RESOURCE_PATH = "/api/health_checks"

    # Check the health of the Forem application server.
    #
    # Returns a simple status object indicating whether the subsystem is healthy.
    #
    # Sends a GET request to +/api/health_checks/app+. Returns a 200 status
    # with a +{"status": "OK"}+ body when the application is running normally,
    # or a 503 when it is unhealthy.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ForemObject] object with a +status+ field
    # @example
    #   result = Forem::HealthCheck.app
    #   puts result.status   # => "OK"
    # @see https://developers.forem.com/api/v1
    def self.app(opts = {})
      resp = request(:get, "/api/health_checks/app", {}, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end

    # Check the health of the Forem database connection.
    #
    # Returns a simple status object indicating whether the subsystem is healthy.
    #
    # Sends a GET request to +/api/health_checks/database+. Returns a 200
    # status when the database is reachable and responsive, or a 503 otherwise.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ForemObject] object with a +status+ field
    # @example
    #   result = Forem::HealthCheck.database
    #   puts result.status   # => "OK"
    # @see https://developers.forem.com/api/v1
    def self.database(opts = {})
      resp = request(:get, "/api/health_checks/database", {}, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end

    # Check the health of the Forem cache layer (e.g., Redis).
    #
    # Returns a simple status object indicating whether the subsystem is healthy.
    #
    # Sends a GET request to +/api/health_checks/cache+. Returns a 200 status
    # when the cache store is reachable and responsive, or a 503 otherwise.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ForemObject] object with a +status+ field
    # @example
    #   result = Forem::HealthCheck.cache
    #   puts result.status   # => "OK"
    # @see https://developers.forem.com/api/v1
    def self.cache(opts = {})
      resp = request(:get, "/api/health_checks/cache", {}, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end
  end
end
