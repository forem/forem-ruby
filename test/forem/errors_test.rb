require "test_helper"

class Forem::ErrorsTest < Minitest::Test
  def test_forem_error_is_standard_error
    err = Forem::ForemError.new("boom")
    assert_kind_of StandardError, err
    assert_equal "boom", err.message
  end

  def test_forem_error_stores_http_attributes
    err = Forem::ForemError.new("fail", http_status: 422, http_body: '{"error":"fail"}', http_headers: {"x-req" => "1"}, code: "invalid")
    assert_equal 422, err.http_status
    assert_equal '{"error":"fail"}', err.http_body
    assert_equal({"x-req" => "1"}, err.http_headers)
    assert_equal "invalid", err.code
  end

  def test_authentication_error_inherits_from_forem_error
    assert Forem::AuthenticationError < Forem::ForemError
  end

  def test_authorization_error_inherits_from_forem_error
    assert Forem::AuthorizationError < Forem::ForemError
  end

  def test_not_found_error_inherits_from_forem_error
    assert Forem::NotFoundError < Forem::ForemError
  end

  def test_conflict_error_inherits_from_forem_error
    assert Forem::ConflictError < Forem::ForemError
  end

  def test_invalid_request_error_inherits_from_forem_error
    assert Forem::InvalidRequestError < Forem::ForemError
  end

  def test_rate_limit_error_inherits_from_forem_error
    assert Forem::RateLimitError < Forem::ForemError
  end

  def test_rate_limit_error_exposes_integer_retry_after_seconds
    error = Forem::RateLimitError.new("slow down", http_headers: { "retry-after" => "12" })

    assert_equal 12, error.retry_after
  end

  def test_rate_limit_error_retry_after_is_nil_when_header_is_absent
    error = Forem::RateLimitError.new("slow down")

    assert_nil error.retry_after
  end

  def test_rate_limit_error_retry_after_is_nil_when_header_is_not_an_integer
    error = Forem::RateLimitError.new("slow down", http_headers: { "retry-after" => "Wed, 21 Oct 2015 07:28:00 GMT" })

    assert_nil error.retry_after
  end

  def test_api_error_inherits_from_forem_error
    assert Forem::APIError < Forem::ForemError
  end

  def test_api_connection_error_inherits_from_forem_error
    assert Forem::APIConnectionError < Forem::ForemError
  end
end
