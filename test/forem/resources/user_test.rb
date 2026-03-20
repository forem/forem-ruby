require "test_helper"

class Forem::UserTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/users", Forem::User.resource_path
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/users/1", status: 200, body: '{"id":1,"username":"alice"}')
    requestor = make_requestor(mock_http)
    result = Forem::User.retrieve(1, requestor: requestor)
    assert_instance_of Forem::User, result
    assert_equal "alice", result.username
  end

  def test_me
    mock_http, _ = stub_http_request(method: :get, path: "/api/users/me", status: 200, body: '{"id":1,"username":"me"}')
    requestor = make_requestor(mock_http)
    result = Forem::User.me(requestor: requestor)
    assert_instance_of Forem::User, result
    assert_equal "me", result.username
  end

  def test_search
    mock_http, _ = stub_http_request(method: :get, path: "/api/users/search", status: 200, body: '[{"id":1,"username":"alice"},{"id":2,"username":"bob"}]')
    requestor = make_requestor(mock_http)
    result = Forem::User.search({ term: "al" }, requestor: requestor)
    assert_instance_of Array, result
    assert_equal 2, result.length
    assert_instance_of Forem::User, result[0]
    assert_equal "alice", result[0].username
  end

  def test_suspend
    mock_http, _ = stub_http_request(method: :put, path: "/api/users/1/suspend", status: 204, body: "")
    requestor = make_requestor(mock_http)
    user = Forem::User.construct_from({"id" => 1})
    result = user.suspend(requestor: requestor)
    assert_equal 204, result.http_status
  end

  def test_unsuspend
    mock_http, _ = stub_http_request(method: :delete, path: "/api/users/1/suspend", status: 204, body: "")
    requestor = make_requestor(mock_http)
    user = Forem::User.construct_from({"id" => 1})
    result = user.unsuspend(requestor: requestor)
    assert_equal 204, result.http_status
  end

  def test_add_limited
    mock_http, _ = stub_http_request(method: :put, path: "/api/users/1/limited", status: 204, body: "")
    requestor = make_requestor(mock_http)
    user = Forem::User.construct_from({"id" => 1})
    result = user.add_limited(requestor: requestor)
    assert_equal 204, result.http_status
  end

  def test_remove_limited
    mock_http, _ = stub_http_request(method: :delete, path: "/api/users/1/limited", status: 204, body: "")
    requestor = make_requestor(mock_http)
    user = Forem::User.construct_from({"id" => 1})
    result = user.remove_limited(requestor: requestor)
    assert_equal 204, result.http_status
  end

  def test_add_spam
    mock_http, _ = stub_http_request(method: :put, path: "/api/users/1/spam", status: 204, body: "")
    requestor = make_requestor(mock_http)
    user = Forem::User.construct_from({"id" => 1})
    result = user.add_spam(requestor: requestor)
    assert_equal 204, result.http_status
  end

  def test_remove_spam
    mock_http, _ = stub_http_request(method: :delete, path: "/api/users/1/spam", status: 204, body: "")
    requestor = make_requestor(mock_http)
    user = Forem::User.construct_from({"id" => 1})
    result = user.remove_spam(requestor: requestor)
    assert_equal 204, result.http_status
  end

  def test_add_trusted
    mock_http, _ = stub_http_request(method: :put, path: "/api/users/1/trusted", status: 204, body: "")
    requestor = make_requestor(mock_http)
    user = Forem::User.construct_from({"id" => 1})
    result = user.add_trusted(requestor: requestor)
    assert_equal 204, result.http_status
  end

  def test_remove_trusted
    mock_http, _ = stub_http_request(method: :delete, path: "/api/users/1/trusted", status: 204, body: "")
    requestor = make_requestor(mock_http)
    user = Forem::User.construct_from({"id" => 1})
    result = user.remove_trusted(requestor: requestor)
    assert_equal 204, result.http_status
  end

  def test_unpublish
    mock_http, _ = stub_http_request(method: :put, path: "/api/users/1/unpublish", status: 204, body: "")
    requestor = make_requestor(mock_http)
    user = Forem::User.construct_from({"id" => 1})
    result = user.unpublish(requestor: requestor)
    assert_equal 204, result.http_status
  end
end
