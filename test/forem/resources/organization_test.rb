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

  def test_class_users_and_articles
    mock_http, captured = stub_http_request(method: :get, path: "/api/organizations/acme/users", status: 200, body: '[{"id":2,"username":"bob"}]')
    requestor = make_requestor(mock_http)
    users = Forem::Organization.users("acme", {}, requestor: requestor)
    assert_equal "bob", users[0].username
    assert_equal "/api/organizations/acme/users", captured[:path]

    mock_http2, captured2 = stub_http_request(method: :get, path: "/api/organizations/acme/articles", status: 200, body: '[{"id":9,"title":"Hello"}]')
    requestor2 = make_requestor(mock_http2)
    articles = Forem::Organization.articles("acme", {}, requestor: requestor2)
    assert_equal "Hello", articles[0].title
    assert_equal "/api/organizations/acme/articles", captured2[:path]
  end

  def test_article_analytics
    body = '[{"id":10,"title":"Post","page_views_count":420,"daily":[{"date":"2026-11-01","page_views":42}]}]'
    mock_http, captured = stub_http_request(method: :get, path: "/api/organizations/7/article_analytics", status: 200, body: body)
    requestor = make_requestor(mock_http)
    result = Forem::Organization.article_analytics(7, { start: "2026-11-01", end: "2026-11-07" }, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.length
    assert_equal 420, result[0].page_views_count
    assert_includes captured[:path], "/api/organizations/7/article_analytics"
    assert_includes captured[:path], "start=2026-11-01"
  end
end
