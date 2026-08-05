$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "forem"
require "minitest/autorun"
require "minitest/mock"

module StubRequestHelper
  def stub_http_request(method:, path:, status:, body:, response_headers: {})
    captured = { method: nil, path: nil, body: nil, headers: {} }
    response = http_response(status: status, body: body, headers: response_headers)

    mock_http = Minitest::Mock.new
    mock_http.expect(:request, response) do |req|
      captured[:method] = req.method
      captured[:path] = req.path
      captured[:body] = req.body
      req.each_header { |k, v| captured[:headers][k] = v }
      true
    end

    [mock_http, captured]
  end

  def http_response(status:, body:, headers: {})
    response = Net::HTTPResponse::CODE_TO_OBJ[status.to_s].new("1.1", status.to_s, "")
    response.instance_variable_set(:@body, body)
    response.instance_variable_set(:@read, true)
    response["content-type"] = "application/json"
    headers.each { |name, value| response[name] = value }
    response
  end

  def make_requestor(mock_http)
    config = Forem::Configuration.new
    config.api_key = "test-key"
    config.max_network_retries = 0
    requestor = Forem::APIRequestor.new(config: config)
    conn_manager = Minitest::Mock.new
    conn_manager.expect(:connection_for, mock_http, [URI], open_timeout: Integer, read_timeout: Integer)
    requestor.instance_variable_set(:@connection_manager, conn_manager)
    requestor
  end
end
