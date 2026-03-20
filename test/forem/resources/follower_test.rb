require "test_helper"

class Forem::FollowerTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/followers", Forem::Follower.resource_path
  end

  def test_list
    mock_http, captured = stub_http_request(method: :get, path: "/api/followers/users", status: 200, body: '[{"id":1,"username":"alice"},{"id":2,"username":"bob"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Follower.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 2, result.data.length
    assert_instance_of Forem::Follower, result.data[0]
    assert_equal "alice", result.data[0].username
    assert_equal "/api/followers/users", captured[:path].split("?").first
  end

  def test_list_default_per_page
    mock_http, _ = stub_http_request(method: :get, path: "/api/followers/users", status: 200, body: "[]")
    requestor = make_requestor(mock_http)
    result = Forem::Follower.list({}, requestor: requestor)
    assert_equal 80, result.per_page
  end

  def test_list_default_page
    mock_http, _ = stub_http_request(method: :get, path: "/api/followers/users", status: 200, body: "[]")
    requestor = make_requestor(mock_http)
    result = Forem::Follower.list({}, requestor: requestor)
    assert_equal 1, result.current_page
  end
end
