require "test_helper"

class Forem::TagTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/tags", Forem::Tag.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/tags", status: 200, body: '[{"id":1,"name":"ruby"},{"id":2,"name":"rails"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Tag.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 2, result.data.length
    assert_instance_of Forem::Tag, result.data[0]
    assert_equal "ruby", result.data[0].name
  end

  def test_supported
    mock_http, captured = stub_http_request(method: :get, path: "/api/tags/supported", status: 200, body: '[{"id":1,"name":"ruby"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Tag.supported({}, requestor: requestor)
    assert_instance_of Array, result
    assert_instance_of Forem::Tag, result[0]
    assert_equal "ruby", result[0].name
    assert_equal "/api/tags/supported", captured[:path]
  end

  def test_create_and_update
    mock_http, captured = stub_http_request(method: :post, path: "/api/tags", status: 201, body: '{"id":10,"name":"rust","supported":true}')
    requestor = make_requestor(mock_http)
    tag = Forem::Tag.create({ name: "rust", supported: true }, requestor: requestor)
    assert_instance_of Forem::Tag, tag
    assert_equal "rust", tag.name
    assert_equal "POST", captured[:method]
    assert_equal({ "name" => "rust", "supported" => true }, JSON.parse(captured[:body]))

    mock_http2, captured2 = stub_http_request(method: :put, path: "/api/tags/10", status: 200, body: '{"id":10,"name":"rust","short_summary":"Systems"}')
    requestor2 = make_requestor(mock_http2)
    updated = Forem::Tag.update(10, { short_summary: "Systems" }, requestor: requestor2)
    assert_equal "Systems", updated.short_summary
    assert_equal "PUT", captured2[:method]
    assert_equal "/api/tags/10", captured2[:path]
  end

  def test_add_and_remove_moderator
    body = '{"tag_id":10,"tag_name":"rust","user_id":42,"username":"alice"}'
    mock_http, captured = stub_http_request(method: :post, path: "/api/tags/10/moderators", status: 201, body: body)
    requestor = make_requestor(mock_http)
    added = Forem::Tag.add_moderator(10, { username: "alice" }, requestor: requestor)
    assert_equal 42, added.user_id
    assert_equal "POST", captured[:method]
    assert_equal "/api/tags/10/moderators", captured[:path]
    assert_equal({ "username" => "alice" }, JSON.parse(captured[:body]))

    mock_http2, captured2 = stub_http_request(method: :delete, path: "/api/tags/10/moderators", status: 200, body: body)
    requestor2 = make_requestor(mock_http2)
    removed = Forem::Tag.remove_moderator(10, { username: "alice" }, requestor: requestor2)
    assert_equal "alice", removed.username
    assert_equal "DELETE", captured2[:method]
    assert_equal "/api/tags/10/moderators", captured2[:path]
    assert_equal({ "username" => "alice" }, JSON.parse(captured2[:body]))
  end
end
