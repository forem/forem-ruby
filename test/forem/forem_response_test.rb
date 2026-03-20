require "test_helper"

class Forem::ForemResponseTest < Minitest::Test
  def test_stores_attributes
    resp = Forem::ForemResponse.new(http_status: 200, http_body: '{"id":1}', http_headers: {"content-type" => "application/json"})
    assert_equal 200, resp.http_status
    assert_equal '{"id":1}', resp.http_body
    assert_equal({"content-type" => "application/json"}, resp.http_headers)
  end

  def test_parsed_body_returns_parsed_json
    resp = Forem::ForemResponse.new(http_status: 200, http_body: '{"id":1,"title":"Hello"}', http_headers: {})
    assert_equal({"id" => 1, "title" => "Hello"}, resp.parsed_body)
  end

  def test_parsed_body_returns_nil_for_empty_body
    resp = Forem::ForemResponse.new(http_status: 204, http_body: "", http_headers: {})
    assert_nil resp.parsed_body
  end
end
