module Forem
  module Services
    # Service for interacting with the Forem Health Check API.
    #
    # In production these endpoints require the +health-check-token+
    # header — pass +token:+ to each call. On localhost the token is
    # bypassed by Forem core, so a local development instance accepts
    # unauthenticated calls.
    #
    # @example Production
    #   client.health_checks.app(token: ENV["FOREM_HEALTH_CHECK_TOKEN"])
    #
    # @example Local development (token not required for localhost)
    #   client.health_checks.app
    #
    # @see HealthCheck
    # @see https://developers.forem.com/api/v1
    class HealthCheckService < BaseService
      # Application-server health.
      # @param token [String, nil] value for the +health-check-token+ header
      #   (required in production; bypassed on localhost).
      # @param opts [Hash] per-request options
      # @return [Forem::ForemObject] response body, e.g.
      #   <tt>{"message" => "App is up!"}</tt>
      def app(token: nil, **opts)
        HealthCheck.app(token: token, **opts_with_requestor(opts))
      end

      # Database connectivity & responsiveness.
      # @param token [String, nil] value for the +health-check-token+ header.
      # @param opts [Hash] per-request options
      # @return [Forem::ForemObject]
      def database(token: nil, **opts)
        HealthCheck.database(token: token, **opts_with_requestor(opts))
      end

      # Cache (Redis) connectivity & responsiveness.
      # @param token [String, nil] value for the +health-check-token+ header.
      # @param opts [Hash] per-request options
      # @return [Forem::ForemObject]
      def cache(token: nil, **opts)
        HealthCheck.cache(token: token, **opts_with_requestor(opts))
      end
    end
  end
end
