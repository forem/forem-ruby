require "test_helper"

class Forem::PageTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/pages", Forem::Page.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/pages", status: 200, body: '[{"id":1,"title":"About"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Page.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::Page, result.data[0]
    assert_equal "About", result.data[0].title
  end

  def test_create
    mock_http, _ = stub_http_request(method: :post, path: "/api/pages", status: 201, body: '{"id":1,"title":"New Page"}')
    requestor = make_requestor(mock_http)
    result = Forem::Page.create({ title: "New Page" }, requestor: requestor)
    assert_instance_of Forem::Page, result
    assert_equal "New Page", result.title
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/pages/1", status: 200, body: '{"id":1,"title":"Found"}')
    requestor = make_requestor(mock_http)
    result = Forem::Page.retrieve(1, requestor: requestor)
    assert_instance_of Forem::Page, result
    assert_equal "Found", result.title
  end

  def test_update
    mock_http, _ = stub_http_request(method: :put, path: "/api/pages/1", status: 200, body: '{"id":1,"title":"Updated"}')
    requestor = make_requestor(mock_http)
    result = Forem::Page.update(1, { title: "Updated" }, requestor: requestor)
    assert_instance_of Forem::Page, result
    assert_equal "Updated", result.title
  end

  def test_delete
    mock_http, captured = stub_http_request(method: :delete, path: "/api/pages/1", status: 204, body: "")
    requestor = make_requestor(mock_http)
    page = Forem::Page.construct_from({"id" => 1})
    page.delete(requestor: requestor)
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/pages/1", captured[:path]
  end
end
