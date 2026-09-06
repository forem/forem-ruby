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

  def test_error_code_is_extracted_from_json_object_body
    body = '{"error":"identity conflict","error_code":"identity_already_linked"}'
    mock_http, _ = stub_http_request(method: :post, path: "/api/admin/users/identities/bulk", status: 409, body: body)
    requestor = make_requestor(mock_http)

    error = assert_raises(Forem::ConflictError) do
      requestor.request(:post, "/api/admin/users/identities/bulk", {})
    end

    assert_equal "identity_already_linked", error.code
    assert_equal "identity conflict", error.message
  end

  def test_error_code_is_nil_when_json_object_omits_it
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/999", status: 404, body: '{"error":"not found"}')
    requestor = make_requestor(mock_http)

    error = assert_raises(Forem::NotFoundError) { requestor.request(:get, "/api/articles/999") }

    assert_nil error.code
  end

  def test_error_code_is_nil_for_non_object_body
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles", status: 500, body: '["internal"]')
    requestor = make_requestor(mock_http)

    error = assert_raises(Forem::APIError) { requestor.request(:get, "/api/articles") }

    assert_nil error.code
  end

  def test_error_code_is_nil_for_empty_body
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles", status: 500, body: "")
    requestor = make_requestor(mock_http)

    error = assert_raises(Forem::APIError) { requestor.request(:get, "/api/articles") }

    assert_nil error.code
  end

  def test_error_code_is_nil_for_malformed_body
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles", status: 500, body: "not-json")
    requestor = make_requestor(mock_http)

    error = assert_raises(Forem::APIError) { requestor.request(:get, "/api/articles") }

    assert_nil error.code
    assert_equal "not-json", error.message
  end

  def test_rate_limit_retry_honors_retry_after_seconds
    rate_limit_response = http_response(
      status: 429,
      body: '{"error":"rate limited"}',
      headers: { "Retry-After" => "3" }
    )
    requestor, sleeps, connection_manager = retrying_requestor(
      rate_limit_response,
      http_response(status: 200, body: '[]')
    )

    response = requestor.request(:get, "/api/articles")

    assert_equal 200, response.http_status
    assert_equal [3], sleeps
    connection_manager.verify
  end

  def test_rate_limit_retry_with_negative_retry_after_uses_jittered_backoff
    rate_limit_response = http_response(
      status: 429,
      body: '{"error":"rate limited"}',
      headers: { "Retry-After" => "-3" }
    )
    requestor, sleeps, connection_manager = retrying_requestor(
      rate_limit_response,
      http_response(status: 200, body: '[]')
    )

    response = requestor.request(:get, "/api/articles")

    assert_equal 200, response.http_status
    assert_operator sleeps.fetch(0), :>=, 1.0
    assert_operator sleeps.fetch(0), :<, 1.5
    connection_manager.verify
  end

  def test_post_is_not_retried_after_a_server_error
    requestor, attempts, = counting_requestor(
      http_response(status: 500, body: '{"error":"boom"}'),
      http_response(status: 201, body: '{"id":1}')
    )

    assert_raises(Forem::APIError) { requestor.request(:post, "/api/articles", { title: "Hi" }) }
    assert_equal 1, attempts.length, "a 5xx may already have been processed; replaying a POST can duplicate it"
  end

  def test_post_is_not_retried_after_a_connection_error
    requestor, attempts, = counting_requestor(
      Net::ReadTimeout.new,
      http_response(status: 201, body: '{"id":1}')
    )

    assert_raises(Forem::APIConnectionError) { requestor.request(:post, "/api/articles", { title: "Hi" }) }
    assert_equal 1, attempts.length, "a timed-out POST may have been processed by the server"
  end

  def test_put_is_still_retried_after_a_server_error
    requestor, attempts, = counting_requestor(
      http_response(status: 500, body: '{"error":"boom"}'),
      http_response(status: 200, body: '{"id":1}')
    )

    response = requestor.request(:put, "/api/articles/1", { title: "Hi" })

    assert_equal 200, response.http_status
    assert_equal 2, attempts.length, "PUT is idempotent, so replaying is safe"
  end

  def test_post_is_retried_after_a_rate_limit
    requestor, attempts, = counting_requestor(
      http_response(status: 429, body: '{"error":"rate limited"}', headers: { "Retry-After" => "1" }),
      http_response(status: 201, body: '{"id":1}')
    )

    response = requestor.request(:post, "/api/articles", { title: "Hi" })

    assert_equal 201, response.http_status
    assert_equal 2, attempts.length, "a 429 is rejected without processing, so replaying cannot duplicate"
  end

  def test_post_is_retried_when_explicitly_marked_idempotent
    requestor, attempts, = counting_requestor(
      http_response(status: 500, body: '{"error":"boom"}'),
      http_response(status: 201, body: '{"id":1}')
    )

    response = requestor.request(:post, "/api/articles", { title: "Hi" }, { idempotent: true })

    assert_equal 201, response.http_status
    assert_equal 2, attempts.length
  end

  def test_idempotent_option_is_not_sent_as_a_header
    mock_http, captured = stub_http_request(method: :post, path: "/api/articles", status: 201, body: '{"id":1}')
    requestor = make_requestor(mock_http)

    requestor.request(:post, "/api/articles", { title: "Hi" }, { idempotent: true })

    refute captured[:headers].key?("idempotent")
  end

  def test_per_request_api_key_override
    mock_http, captured = stub_http_request(method: :get, path: "/api/articles", status: 200, body: '[]')
    requestor = make_requestor(mock_http)
    requestor.request(:get, "/api/articles", {}, { api_key: "override-key" })
    assert_equal "override-key", captured[:headers]["api-key"]
  end

  private

  # Like retrying_requestor, but tolerates the request NOT being replayed and
  # reports how many attempts actually reached the transport. A queued entry
  # that is an Exception is raised instead of returned.
  def counting_requestor(*responses, retries: 1)
    queued = responses.dup
    attempts = []
    http = Object.new
    http.define_singleton_method(:request) do |request|
      attempts << request
      nxt = queued.shift
      raise nxt if nxt.is_a?(Exception)

      nxt
    end

    @config.max_network_retries = retries
    requestor = Forem::APIRequestor.new(config: @config)
    connection_manager = Object.new
    connection_manager.define_singleton_method(:connection_for) { |_uri, **_kwargs| http }
    requestor.instance_variable_set(:@connection_manager, connection_manager)

    sleeps = []
    requestor.define_singleton_method(:sleep) { |seconds| sleeps << seconds }
    [requestor, attempts, sleeps]
  end

  def retrying_requestor(*responses)
    queued_responses = responses.dup
    http = Object.new
    http.define_singleton_method(:request) { |_request| queued_responses.shift }

    @config.max_network_retries = responses.length - 1
    requestor = Forem::APIRequestor.new(config: @config)
    connection_manager = Minitest::Mock.new
    responses.length.times do
      connection_manager.expect(
        :connection_for,
        http,
        [URI],
        open_timeout: Integer,
        read_timeout: Integer
      )
    end
    requestor.instance_variable_set(:@connection_manager, connection_manager)

    sleeps = []
    requestor.define_singleton_method(:sleep) { |seconds| sleeps << seconds }
    [requestor, sleeps, connection_manager]
  end
end
