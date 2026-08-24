require "json"

module Forem
  # Base error class for all errors raised by the forem-ruby library.
  #
  # Every error exposes the raw HTTP context (status code, body, headers) so
  # callers can inspect the upstream response without re-issuing the request.
  #
  # @example Rescuing a specific subclass
  #   begin
  #     Forem::Article.retrieve(99999999)
  #   rescue Forem::NotFoundError => e
  #     puts "#{e.http_status}: #{e.message}"
  #   end
  #
  # @example Rescuing any Forem error
  #   rescue Forem::ForemError => e
  #     logger.error(e.message)
  #   end
  class ForemError < StandardError
    # @return [Integer, nil] the HTTP status code returned by the server
    #   (e.g. +401+, +404+, +429+), or +nil+ if no HTTP response was received.
    attr_reader :http_status

    # @return [String, nil] the raw HTTP response body as a string, or +nil+.
    attr_reader :http_body

    # @return [Hash, nil] a hash of HTTP response headers, or +nil+.
    attr_reader :http_headers

    # @return [String, nil] an optional machine-readable error code extracted
    #   from the API response body, or +nil+.
    attr_reader :code

    # Initialize a new ForemError.
    #
    # @param message [String, nil] a human-readable description of the error.
    # @param http_status [Integer, nil] the HTTP status code from the response.
    # @param http_body [String, nil] the raw HTTP response body.
    # @param http_headers [Hash, nil] a hash of HTTP response headers.
    # @param code [String, nil] a machine-readable error code from the API.
    # @return [ForemError]
    def initialize(message = nil, http_status: nil, http_body: nil, http_headers: nil, code: nil)
      @http_status = http_status
      @http_body = http_body
      @http_headers = http_headers
      @code = code
      super(message)
    end

    # The response body parsed as JSON.
    #
    # Useful when the API returns structured detail alongside an error. An empty
    # or unparseable body yields +nil+.
    #
    # @return [Hash, Array, nil] the parsed body, or +nil+ when there is
    #   nothing parseable to return.
    #
    # @example Reading a field the API returned with the error
    #   begin
    #     client.badge_achievements.create(user_id: 123, badge_id: 45)
    #   rescue Forem::ConflictError => e
    #     e.parsed_body&.dig("achievement_id")
    #   end
    def parsed_body
      return @parsed_body if defined?(@parsed_body)

      @parsed_body = (JSON.parse(http_body) if http_body && !http_body.empty?)
    rescue JSON::ParserError
      @parsed_body = nil
    end
  end

  # Raised when the server responds with HTTP 401 Unauthorized.
  #
  # Typically indicates a missing or invalid API key.
  #
  # @see https://developers.forem.com/api/v1
  class AuthenticationError < ForemError; end

  # Raised when the server responds with HTTP 403 Forbidden.
  #
  # Indicates the authenticated user does not have permission to perform
  # the requested action.
  #
  # @see https://developers.forem.com/api/v1
  class AuthorizationError < ForemError; end

  # Raised when the server responds with HTTP 404 Not Found.
  #
  # The requested resource does not exist on the server.
  #
  # @see https://developers.forem.com/api/v1
  class NotFoundError < ForemError; end

  # Raised when the server responds with HTTP 409 Conflict.
  #
  # Usually indicates a duplicate resource or a state conflict (e.g. trying
  # to publish an article that is already published).
  #
  # @see https://developers.forem.com/api/v1
  class ConflictError < ForemError; end

  # Raised when the server responds with HTTP 422 Unprocessable Entity.
  #
  # The request parameters failed server-side validation.
  #
  # @see https://developers.forem.com/api/v1
  class InvalidRequestError < ForemError; end

  # Raised when the server responds with HTTP 429 Too Many Requests.
  #
  # The client has exceeded its request quota. The library will automatically
  # retry rate-limited requests up to {Configuration#max_network_retries}
  # times, honoring integer +Retry-After+ seconds when supplied and otherwise
  # using exponential back-off.
  #
  # @see https://developers.forem.com/api/v1
  class RateLimitError < ForemError
    # Return the number of seconds requested by the server before retrying.
    #
    # @return [Integer, nil] +Retry-After+ seconds when the normalized header
    #   contains only ASCII decimal digits, or +nil+ otherwise.
    def retry_after
      value = http_headers&.fetch("retry-after", nil)
      Integer(value, 10) if value.is_a?(String) && value.match?(/\A[0-9]+\z/)
    end
  end

  # Raised when the server returns any HTTP 5xx error or an unrecognised
  # non-2xx status code not covered by a more specific subclass.
  #
  # @see https://developers.forem.com/api/v1
  class APIError < ForemError; end

  # Raised when a network-level error prevents the library from reaching the
  # Forem server at all (e.g. DNS failure, connection refused, timeout).
  #
  # The library will automatically retry up to
  # {Configuration#max_network_retries} times before re-raising.
  class APIConnectionError < ForemError; end
end
