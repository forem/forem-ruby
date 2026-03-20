require "test_helper"

class Forem::OrganizationTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/organizations", Forem::Organization.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/organizations", status: 200, body: '[{"id":1,"name":"Acme"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Organization.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Organization, result.data[0]
    assert_equal "Acme", result.data[0].name
  end

  def test_create
    mock_http, _ = stub_http_request(method: :post, path: "/api/organizations", status: 201, body: '{"id":1,"name":"NewOrg"}')
    requestor = make_requestor(mock_http)
    result = Forem::Organization.create({ organization: { name: "NewOrg" } }, requestor: requestor)
    assert_instance_of Forem::Organization, result
    assert_equal "NewOrg", result.name
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/organizations/1", status: 200, body: '{"id":1,"name":"Acme"}')
    requestor = make_requestor(mock_http)
    result = Forem::Organization.retrieve(1, requestor: requestor)
    assert_instance_of Forem::Organization, result
    assert_equal "Acme", result.name
  end

  def test_update
    mock_http, _ = stub_http_request(method: :put, path: "/api/organizations/1", status: 200, body: '{"id":1,"name":"Updated"}')
    requestor = make_requestor(mock_http)
    result = Forem::Organization.update(1, { organization: { name: "Updated" } }, requestor: requestor)
    assert_instance_of Forem::Organization, result
    assert_equal "Updated", result.name
  end

  def test_delete_class_method
    mock_http, _ = stub_http_request(method: :delete, path: "/api/organizations/1", status: 200, body: '{"id":1}')
    requestor = make_requestor(mock_http)
    result = Forem::Organization.delete(1, requestor: requestor)
    assert_instance_of Forem::Organization, result
  end

  def test_users
    mock_http, _ = stub_http_request(method: :get, path: "/api/organizations/1/users", status: 200, body: '[{"id":10,"username":"alice"}]')
    requestor = make_requestor(mock_http)
    org = Forem::Organization.construct_from({"id" => 1})
    result = org.users({}, requestor: requestor)
    assert_instance_of Array, result
    assert_instance_of Forem::User, result[0]
    assert_equal "alice", result[0].username
  end

  def test_articles
    mock_http, _ = stub_http_request(method: :get, path: "/api/organizations/1/articles", status: 200, body: '[{"id":5,"title":"Org Article"}]')
    requestor = make_requestor(mock_http)
    org = Forem::Organization.construct_from({"id" => 1})
    result = org.articles({}, requestor: requestor)
    assert_instance_of Array, result
    assert_instance_of Forem::Article, result[0]
    assert_equal "Org Article", result[0].title
  end
end
