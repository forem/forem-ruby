require "json"

module Forem
  class ForemResponse
    attr_reader :http_status, :http_body, :http_headers

    def initialize(http_status:, http_body:, http_headers:)
      @http_status = http_status
      @http_body = http_body
      @http_headers = http_headers
    end

    def parsed_body
      return nil if http_body.nil? || http_body.empty?
      @parsed_body ||= JSON.parse(http_body)
    end
  end
end
