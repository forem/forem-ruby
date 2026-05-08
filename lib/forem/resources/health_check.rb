module Forem
  # Provides access to the health-check endpoints of a Forem instance.
  #
  # Health checks let you verify that the various subsystems of a Forem
  # deployment are operational. There are three separate checks: the
  # application server, the database, and the cache layer.
  #
  # == Authentication
  #
  # In production, the endpoints require an +health-check-token+ header
  # whose value matches the instance's
  # +Settings::General.health_check_token+ setting. The Forem controller
  # bypasses the token check for requests originating from +localhost+,
  # so a local-development instance accepts unauthenticated calls.
  #
  # Pass the token via the +token:+ keyword on each method (or on the
  # service-level wrapper). The +api-key+ header is *not* used by these
  # endpoints — the token is a separate, dedicated mechanism.
  #
  # @example Production: pass the configured token
  #   client.health_checks.app(token: ENV.fetch("FOREM_HEALTH_CHECK_TOKEN"))
  #   #=> #<Forem::ForemObject {"message" => "App is up!"}>
  #
  # @example Local-development Forem (token bypassed for localhost)
  #   client.health_checks.app
  #   #=> #<Forem::ForemObject {"message" => "App is up!"}>
  #
  # @see https://developers.forem.com/api/v1
  class HealthCheck < APIResource
    OBJECT_NAME = "health_check"
    RESOURCE_PATH = "/api/health_checks"

    # Application-server health.
    # @param token [String, nil] value for the +health-check-token+ header
    #   (required in production).
    # @param opts [Hash] per-request options
    # @return [Forem::ForemObject] response body
    def self.app(token: nil, **opts)
      check("/api/health_checks/app", token, opts)
    end

    # Database connectivity & responsiveness.
    # @param token [String, nil] value for the +health-check-token+ header.
    # @param opts [Hash] per-request options
    # @return [Forem::ForemObject] response body
    def self.database(token: nil, **opts)
      check("/api/health_checks/database", token, opts)
    end

    # Cache (Redis) connectivity & responsiveness.
    # @param token [String, nil] value for the +health-check-token+ header.
    # @param opts [Hash] per-request options
    # @return [Forem::ForemObject] response body
    def self.cache(token: nil, **opts)
      check("/api/health_checks/cache", token, opts)
    end

    def self.check(path, token, opts)
      requestor = opts[:requestor]
      opts = opts.dup
      if token
        existing = opts[:headers] || {}
        opts[:headers] = existing.merge("health-check-token" => token)
      end
      resp = request(:get, path, {}, opts)
      Forem::ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end
    private_class_method :check
  end
end
