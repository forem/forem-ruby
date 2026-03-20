module Forem
  class ForemError < StandardError
    attr_reader :http_status, :http_body, :http_headers, :code

    def initialize(message = nil, http_status: nil, http_body: nil, http_headers: nil, code: nil)
      @http_status = http_status
      @http_body = http_body
      @http_headers = http_headers
      @code = code
      super(message)
    end
  end

  class AuthenticationError < ForemError; end
  class AuthorizationError < ForemError; end
  class NotFoundError < ForemError; end
  class ConflictError < ForemError; end
  class InvalidRequestError < ForemError; end
  class RateLimitError < ForemError; end
  class APIError < ForemError; end
  class APIConnectionError < ForemError; end
end
