require "test_helper"

class Forem::FollowTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/follows", Forem::Follow.resource_path
  end

  def test_list
    mock_http, captured = stub_http_request(method: :get, path: "/api/follows/tags", status: 200, body: '[{"id":1,"name":"ruby"},{"id":2,"name":"rails"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Follow.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 2, result.data.length
    assert_instance_of Forem::Follow, result.data[0]
    assert_equal "ruby", result.data[0].name
    assert_equal "/api/follows/tags", captured[:path].split("?").first
  end

  def test_list_default_per_page
    mock_http, _ = stub_http_request(method: :get, path: "/api/follows/tags", status: 200, body: "[]")
    requestor = make_requestor(mock_http)
    result = Forem::Follow.list({}, requestor: requestor)
    assert_equal 30, result.per_page
  end

  def test_list_default_page
    mock_http, _ = stub_http_request(method: :get, path: "/api/follows/tags", status: 200, body: "[]")
    requestor = make_requestor(mock_http)
    result = Forem::Follow.list({}, requestor: requestor)
    assert_equal 1, result.current_page
  end

  def test_create
    mock_http, captured = stub_http_request(method: :post, path: "/api/follows", status: 201, body: '{"id":1,"name":"ruby"}')
    requestor = make_requestor(mock_http)
    result = Forem::Follow.create({ followable_type: "Tag", followable_id: 1 }, requestor: requestor)
    assert_instance_of Forem::Follow, result
    assert_equal "POST", captured[:method]
    assert_equal "/api/follows", captured[:path]
  end
end
