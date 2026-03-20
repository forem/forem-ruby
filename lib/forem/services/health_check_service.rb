module Forem
  module Services
    # Service for interacting with the Forem Health Check API.
    #
    # Health check endpoints allow you to verify that the various subsystems
    # of a Forem instance (application server, database, cache) are operating
    # correctly.
    # Access via {Client#health_checks}. All methods inject the client's
    # requestor automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   client.health_checks.app
    #   client.health_checks.database
    #   client.health_checks.cache
    #
    # @see HealthCheck
    # @see https://developers.forem.com/api/v1#tag/health-checks
    class HealthCheckService < BaseService
      # Check the overall application health.
      #
      # Returns HTTP 200 when the application is healthy.
      #
      # @param opts [Hash] per-request options
      # @return [HealthCheck] health status of the application server
      #
      # @example
      #   status = client.health_checks.app
      #
      # @see https://developers.forem.com/api/v1#tag/health-checks/operation/getHealthCheck
      def app(opts = {})
        HealthCheck.app(opts_with_requestor(opts))
      end

      # Check the database connectivity and health.
      #
      # Returns HTTP 200 when the database is reachable and healthy.
      #
      # @param opts [Hash] per-request options
      # @return [HealthCheck] health status of the database layer
      #
      # @example
      #   status = client.health_checks.database
      #
      # @see https://developers.forem.com/api/v1#tag/health-checks/operation/getHealthCheckDatabase
      def database(opts = {})
        HealthCheck.database(opts_with_requestor(opts))
      end

      # Check the cache connectivity and health.
      #
      # Returns HTTP 200 when the cache (Redis) is reachable and healthy.
      #
      # @param opts [Hash] per-request options
      # @return [HealthCheck] health status of the cache layer
      #
      # @example
      #   status = client.health_checks.cache
      #
      # @see https://developers.forem.com/api/v1#tag/health-checks/operation/getHealthCheckCache
      def cache(opts = {})
        HealthCheck.cache(opts_with_requestor(opts))
      end
    end
  end
end
