require "json"

module Forem
  # Wraps a raw HTTP response from the Forem API.
  #
  # {ForemResponse} is an internal value object created by {APIRequestor} after
  # every successful round-trip to the server. It normalises the Net::HTTP
  # response into a simple struct and provides lazy JSON parsing via
  # {#parsed_body}.
  #
  # @example Inspecting a raw response (inside a custom requestor)
  #   resp = requestor.request(:get, "/api/articles/1")
  #   resp.http_status   #=> 200
  #   resp.parsed_body   #=> { "id" => 1, "title" => "Hello" }
  class ForemResponse
    # @return [Integer] the HTTP status code of the response (e.g. +200+, +404+).
    attr_reader :http_status

    # @return [String] the raw, unparsed HTTP response body as a string.
    attr_reader :http_body

    # @return [Hash] a hash of downcased HTTP response header names to their
    #   string values (e.g. <tt>{ "content-type" => "application/json" }</tt>).
    attr_reader :http_headers

    # Create a new ForemResponse.
    #
    # @param http_status [Integer] the HTTP status code.
    # @param http_body [String] the raw response body.
    # @param http_headers [Hash] the response headers.
    # @return [ForemResponse]
    def initialize(http_status:, http_body:, http_headers:)
      @http_status = http_status
      @http_body = http_body
      @http_headers = http_headers
    end

    # Parse the response body as JSON, caching the result after the first call.
    #
    # Returns +nil+ when the body is absent or blank (e.g. HTTP 204 No Content).
    #
    # @return [Hash, Array, nil] the decoded JSON value, or +nil+ if the body
    #   is empty.
    # @raise [JSON::ParserError] if the body is non-empty but not valid JSON.
    def parsed_body
      return nil if http_body.nil? || http_body.empty?
      @parsed_body ||= JSON.parse(http_body)
    end
  end
end
