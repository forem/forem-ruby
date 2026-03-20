# test/forem/api_requestor_test.rb
require "test_helper"

class Forem::APIRequestorTest < Minitest::Test
  include StubRequestHelper

  def setup
    @config = Forem::Configuration.new
    @config.api_key = "test-api-key"
    @config.max_network_retries = 0
  end

  def test_get_request_sends_correct_headers
    mock_http, captured = stub_http_request(method: :get, path: "/api/articles", status: 200, body: '[{"id":1}]')
    requestor = Forem::APIRequestor.new(config: @config)
    conn_manager = Minitest::Mock.new
    conn_manager.expect(:connection_for, mock_http, [URI], open_timeout: Integer, read_timeout: Integer)
    requestor.instance_variable_set(:@connection_manager, conn_manager)

    resp = requestor.request(:get, "/api/articles")
    assert_equal 200, resp.http_status
    assert_equal "test-api-key", captured[:headers]["api-key"]
    assert_includes captured[:headers]["accept"], "application/vnd.forem.api-v1+json"
    assert_includes captured[:headers]["user-agent"], "forem-ruby/"
    mock_http.verify
    conn_manager.verify
  end

  def test_post_request_sends_json_body
    mock_http, captured = stub_http_request(method: :post, path: "/api/articles", status: 201, body: '{"id":1}')
    requestor = Forem::APIRequestor.new(config: @config)
    conn_manager = Minitest::Mock.new
    conn_manager.expect(:connection_for, mock_http, [URI], open_timeout: Integer, read_timeout: Integer)
    requestor.instance_variable_set(:@connection_manager, conn_manager)

    resp = requestor.request(:post, "/api/articles", { article: { title: "Hello" } })
    assert_equal 201, resp.http_status
    parsed_body = JSON.parse(captured[:body])
    assert_equal "Hello", parsed_body["article"]["title"]
    assert_equal "application/json", captured[:headers]["content-type"]
    mock_http.verify
  end

  def test_401_raises_authentication_error
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles", status: 401, body: '{"error":"unauthorized","status":401}')
    requestor = make_requestor(mock_http)
    err = assert_raises(Forem::AuthenticationError) { requestor.request(:get, "/api/articles") }
    assert_equal 401, err.http_status
    assert_includes err.message, "unauthorized"
  end

  def test_404_raises_not_found_error
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/999", status: 404, body: '{"error":"not found","status":404}')
    requestor = make_requestor(mock_http)
    assert_raises(Forem::NotFoundError) { requestor.request(:get, "/api/articles/999") }
  end

  def test_422_raises_invalid_request_error
    mock_http, _ = stub_http_request(method: :post, path: "/api/articles", status: 422, body: '{"error":"Title can\'t be blank","status":422}')
    requestor = make_requestor(mock_http)
    err = assert_raises(Forem::InvalidRequestError) { requestor.request(:post, "/api/articles", {}) }
    assert_includes err.message, "Title"
  end

  def test_429_raises_rate_limit_error
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles", status: 429, body: '{"error":"rate limited","status":429}')
    requestor = make_requestor(mock_http)
    assert_raises(Forem::RateLimitError) { requestor.request(:get, "/api/articles") }
  end

  def test_500_raises_api_error
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles", status: 500, body: '{"error":"internal","status":500}')
    requestor = make_requestor(mock_http)
    assert_raises(Forem::APIError) { requestor.request(:get, "/api/articles") }
  end

  def test_errors_array_format_joined
    mock_http, _ = stub_http_request(method: :post, path: "/api/articles", status: 422, body: '{"errors":["Title blank","Body blank"]}')
    requestor = make_requestor(mock_http)
    err = assert_raises(Forem::InvalidRequestError) { requestor.request(:post, "/api/articles", {}) }
    assert_includes err.message, "Title blank"
    assert_includes err.message, "Body blank"
  end

  def test_per_request_api_key_override
    mock_http, captured = stub_http_request(method: :get, path: "/api/articles", status: 200, body: '[]')
    requestor = make_requestor(mock_http)
    requestor.request(:get, "/api/articles", {}, { api_key: "override-key" })
    assert_equal "override-key", captured[:headers]["api-key"]
  end
end
