require "json"
require "uri"
require "securerandom"

module Forem
  class APIRequestor
    def initialize(config: Forem.configuration)
      @config = config
      @connection_manager = ConnectionManager.new
    end

    def request(method, path, params = {}, opts = {})
      api_key = opts.delete(:api_key) || @config.api_key
      api_base = opts.delete(:api_base) || @config.api_base
      uri = URI("#{api_base}#{path}")

      retries_left = @config.max_network_retries
      begin
        response = execute_request(method, uri, params, api_key)
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

    def execute_request(method, uri, params, api_key)
      http = @connection_manager.connection_for(uri, open_timeout: @config.open_timeout, read_timeout: @config.read_timeout)
      request = build_request(method, uri, params, api_key)

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

    def build_request(method, uri, params, api_key)
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
      req
    end

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

    def headers_to_hash(http_response)
      h = {}
      http_response.each_header { |k, v| h[k] = v }
      h
    end

    def retryable_error?(error)
      case error
      when RateLimitError then true
      when APIError then error.http_status >= 500
      else false
      end
    end

    def backoff_duration(retry_count)
      (0.5 * (2**retry_count)) + rand * 0.5
    end
  end
end
