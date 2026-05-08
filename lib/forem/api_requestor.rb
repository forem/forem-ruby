require "json"
require "uri"
require "securerandom"

module Forem
  # Executes authenticated HTTP requests against the Forem API.
  #
  # {APIRequestor} is the single entry-point for all network I/O in the
  # library. It builds requests (including authentication headers), delegates
  # transport to a {ConnectionManager}, parses the response, maps HTTP error
  # status codes to typed {ForemError} subclasses, and applies automatic
  # retry logic for transient failures.
  #
  # Each {Forem::Client} owns its own {APIRequestor}, built from the
  # client's {Configuration}. There is no global default requestor — every
  # call must originate from a specific client instance (or pass an
  # explicit +:requestor+ option to a class-level resource method).
  #
  # @example Constructing directly (uncommon — prefer {Forem::Client.new})
  #   config = Forem::Configuration.new
  #   config.api_key = "my_key"
  #   requestor = Forem::APIRequestor.new(config: config)
  #   requestor.request(:get, "/api/articles")
  class APIRequestor
    # Create a new APIRequestor.
    #
    # @param config [Configuration] the configuration to use for this
    #   requestor.
    # @return [APIRequestor]
    def initialize(config:)
      @config = config
      @connection_manager = ConnectionManager.new
    end

    # Execute an HTTP request against the Forem API.
    #
    # Builds the request, attaches authentication headers, sends it, and
    # returns a {ForemResponse}. On HTTP 4xx/5xx responses the method raises
    # the appropriate {ForemError} subclass. Transient failures
    # ({APIConnectionError}, {RateLimitError}, server 5xx) are automatically
    # retried up to {Configuration#max_network_retries} times with exponential
    # back-off.
    #
    # @param method [Symbol] the HTTP verb — +:get+, +:post+, +:put+, or
    #   +:delete+.
    # @param path [String] the API path relative to {Configuration#api_base}
    #   (e.g. +"/api/articles"+).
    # @param params [Hash] query parameters for GET requests, or the JSON
    #   request body for POST/PUT requests. Defaults to +{}+.
    # @param opts [Hash] per-request overrides.
    # @option opts [String] :api_key override the API key for this request.
    # @option opts [String] :api_base override the base URL for this request.
    # @option opts [APIRequestor] :requestor an alternative requestor to use
    #   (consumed by higher-level helpers before reaching this method).
    # @return [ForemResponse] the parsed response wrapper.
    # @raise [AuthenticationError] on HTTP 401.
    # @raise [AuthorizationError] on HTTP 403.
    # @raise [NotFoundError] on HTTP 404.
    # @raise [ConflictError] on HTTP 409.
    # @raise [InvalidRequestError] on HTTP 422.
    # @raise [RateLimitError] on HTTP 429.
    # @raise [APIError] on other HTTP 4xx/5xx responses.
    # @raise [APIConnectionError] when a network-level error prevents the
    #   request from reaching the server and retries are exhausted.
    #
    # @example Fetching articles with pagination
    #   resp = requestor.request(:get, "/api/articles", { page: 2, per_page: 10 })
    #   resp.http_status  #=> 200
    #   resp.parsed_body  #=> [{ "id" => 1, ... }, ...]
    #
    # @see https://developers.forem.com/api/v1
    def request(method, path, params = {}, opts = {})
      api_key = opts.delete(:api_key) || @config.api_key
      api_base = opts.delete(:api_base) || @config.api_base
      extra_headers = opts.delete(:headers) || {}
      uri = URI("#{api_base}#{path}")

      retries_left = @config.max_network_retries
      begin
        response = execute_request(method, uri, params, api_key, extra_headers)
        handle_error_response(response) if response.http_status >= 400
        response
      rescue Forem::APIConnectionError
        if retries_left > 0
          retries_left -= 1
          sleep backoff_duration(@config.max_network_retries - retries_left)
          retry
        end
        raise
      rescue Forem::RateLimitError, Forem::APIError => e
        if retries_left > 0 && retryable_error?(e)
          retries_left -= 1
          sleep backoff_duration(@config.max_network_retries - retries_left)
          retry
        end
        raise
      end
    end

    private

    # Send the HTTP request through the connection manager and return a
    # {ForemResponse}.
    #
    # @param method [Symbol] the HTTP verb.
    # @param uri [URI] the fully-qualified request URI.
    # @param params [Hash] parameters/body payload.
    # @param api_key [String, nil] the API key to attach.
    # @return [ForemResponse]
    # @raise [APIConnectionError] on any network-level exception.
    def execute_request(method, uri, params, api_key, extra_headers = {})
      http = @connection_manager.connection_for(uri, open_timeout: @config.open_timeout, read_timeout: @config.read_timeout)
      request = build_request(method, uri, params, api_key, extra_headers)

      begin
        http_response = http.request(request)
      rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, Errno::EHOSTUNREACH, SocketError => e
        raise APIConnectionError.new("Connection to #{uri.host} failed: #{e.message}")
      end

      ForemResponse.new(
        http_status: http_response.code.to_i,
        http_body: http_response.body,
        http_headers: headers_to_hash(http_response)
      )
    end

    # Build a Net::HTTPRequest object for the given method and parameters.
    #
    # Sets +api-key+, +Accept+, and +User-Agent+ headers on every request.
    # POST and PUT requests encode +params+ as a JSON body and set
    # +Content-Type: application/json+. GET requests append +params+ as a
    # URL query string.
    #
    # @param method [Symbol] the HTTP verb (+:get+, +:post+, +:put+, +:delete+).
    # @param uri [URI] the request URI (modified in-place for GET params).
    # @param params [Hash] the parameters or body payload.
    # @param api_key [String, nil] the API key value.
    # @return [Net::HTTPRequest] the fully-configured request object.
    # @raise [ArgumentError] if +method+ is not one of the supported verbs.
    def build_request(method, uri, params, api_key, extra_headers = {})
      req = case method
            when :get
              uri.query = URI.encode_www_form(params) unless params.empty?
              Net::HTTP::Get.new(uri)
            when :post
              r = Net::HTTP::Post.new(uri)
              r.body = JSON.generate(params) unless params.empty?
              r["Content-Type"] = "application/json"
              r
            when :put
              r = Net::HTTP::Put.new(uri)
              r.body = JSON.generate(params) unless params.empty?
              r["Content-Type"] = "application/json"
              r
            when :delete
              Net::HTTP::Delete.new(uri)
            else
              raise ArgumentError, "Unsupported HTTP method: #{method}"
            end

      req["api-key"] = api_key if api_key
      req["Accept"] = "application/vnd.forem.api-v1+json"
      req["User-Agent"] = "forem-ruby/#{Forem::VERSION} ruby/#{RUBY_VERSION}"
      extra_headers.each { |name, value| req[name.to_s] = value.to_s }
      req
    end

    # Raise the appropriate {ForemError} subclass for a non-2xx response.
    #
    # @param response [ForemResponse] the error response.
    # @return [void]
    # @raise [ForemError] always raises a subclass matching the HTTP status.
    def handle_error_response(response)
      message = extract_error_message(response)
      kwargs = {
        http_status: response.http_status,
        http_body: response.http_body,
        http_headers: response.http_headers,
      }

      error_class = case response.http_status
                    when 401 then AuthenticationError
                    when 403 then AuthorizationError
                    when 404 then NotFoundError
                    when 409 then ConflictError
                    when 422 then InvalidRequestError
                    when 429 then RateLimitError
                    else APIError
                    end

      raise error_class.new(message, **kwargs)
    end

    # Extract a human-readable error message from an error response.
    #
    # Looks for +error+ (string) or +errors+ (array) keys in the JSON body.
    # Falls back to the raw body string if parsing fails or the expected keys
    # are absent.
    #
    # @param response [ForemResponse] the error response.
    # @return [String] the best available error message.
    def extract_error_message(response)
      body = response.parsed_body
      return response.http_body unless body.is_a?(Hash)

      if body["error"]
        body["error"]
      elsif body["errors"].is_a?(Array)
        body["errors"].join(", ")
      else
        response.http_body
      end
    rescue JSON::ParserError
      response.http_body
    end

    # Convert a Net::HTTPResponse header enumerable into a plain Hash.
    #
    # @param http_response [Net::HTTPResponse] the raw response object.
    # @return [Hash{String => String}] downcased header names mapped to values.
    def headers_to_hash(http_response)
      h = {}
      http_response.each_header { |k, v| h[k] = v }
      h
    end

    # Determine whether a given error is eligible for an automatic retry.
    #
    # {RateLimitError} is always retryable. {APIError} is retryable only when
    # the HTTP status is 500 or greater (server errors).
    #
    # @param error [ForemError] the error to evaluate.
    # @return [Boolean] +true+ if the request should be retried.
    def retryable_error?(error)
      case error
      when RateLimitError then true
      when APIError then error.http_status >= 500
      else false
      end
    end

    # Calculate the sleep duration before the next retry attempt.
    #
    # Uses truncated exponential back-off with jitter:
    # <tt>(0.5 * 2^retry_count) + rand(0..0.5)</tt> seconds.
    #
    # @param retry_count [Integer] how many retries have already been attempted
    #   (1-based: pass 1 for the first retry).
    # @return [Float] seconds to sleep before retrying.
    def backoff_duration(retry_count)
      (0.5 * (2**retry_count)) + rand * 0.5
    end
  end
end
