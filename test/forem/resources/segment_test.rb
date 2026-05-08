require "test_helper"

class Forem::SegmentTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/segments", Forem::Segment.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/segments", status: 200, body: '[{"id":1,"name":"Segment A"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Segment.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::Segment, result.data[0]
    assert_equal "Segment A", result.data[0].name
  end

  def test_create
    mock_http, _ = stub_http_request(method: :post, path: "/api/segments", status: 201, body: '{"id":1,"name":"New Segment"}')
    requestor = make_requestor(mock_http)
    result = Forem::Segment.create({ name: "New Segment" }, requestor: requestor)
    assert_instance_of Forem::Segment, result
    assert_equal "New Segment", result.name
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/segments/1", status: 200, body: '{"id":1,"name":"Found"}')
    requestor = make_requestor(mock_http)
    result = Forem::Segment.retrieve(1, requestor: requestor)
    assert_instance_of Forem::Segment, result
    assert_equal "Found", result.name
  end

  def test_delete
    mock_http, captured = stub_http_request(method: :delete, path: "/api/segments/1", status: 204, body: "")
    requestor = make_requestor(mock_http)
    segment = Forem::Segment.construct_from({"id" => 1})
    segment.delete(requestor: requestor)
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/segments/1", captured[:path]
  end

  def test_users
    mock_http, captured = stub_http_request(method: :get, path: "/api/segments/1/users", status: 200, body: '[{"id":10,"username":"alice"}]')
    requestor = make_requestor(mock_http)
    segment = Forem::Segment.construct_from({"id" => 1})
    result = segment.users({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.length
    assert_instance_of Forem::User, result[0]
    assert_equal "alice", result[0].username
    assert_equal "GET", captured[:method]
    assert_equal "/api/segments/1/users", captured[:path].split("?").first
  end

  def test_add_users
    mock_http, captured = stub_http_request(method: :put, path: "/api/segments/1/add_users", status: 204, body: "")
    requestor = make_requestor(mock_http)
    segment = Forem::Segment.construct_from({"id" => 1})
    result = segment.add_users({ user_ids: [10, 11] }, requestor: requestor)
    assert_equal 204, result.http_status
    assert_equal "PUT", captured[:method]
    assert_equal "/api/segments/1/add_users", captured[:path]
  end

  def test_remove_users
    mock_http, captured = stub_http_request(method: :put, path: "/api/segments/1/remove_users", status: 204, body: "")
    requestor = make_requestor(mock_http)
    segment = Forem::Segment.construct_from({"id" => 1})
    result = segment.remove_users({ user_ids: [10] }, requestor: requestor)
    assert_equal 204, result.http_status
    assert_equal "PUT", captured[:method]
    assert_equal "/api/segments/1/remove_users", captured[:path]
  end
end
