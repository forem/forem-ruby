require "test_helper"

class Forem::AdminUserTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/admin/users", Forem::AdminUser.resource_path
  end

  def test_create
    mock_http, captured = stub_http_request(method: :post, path: "/api/admin/users", status: 201, body: '{"id":1,"username":"newuser","email":"newuser@example.com"}')
    requestor = make_requestor(mock_http)
    result = Forem::AdminUser.create({ user: { email: "newuser@example.com", username: "newuser" } }, requestor: requestor)
    assert_instance_of Forem::AdminUser, result
    assert_equal "newuser", result.username
    assert_equal "POST", captured[:method]
    assert_equal "/api/admin/users", captured[:path]
  end
end
