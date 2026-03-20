require "test_helper"

class Forem::BillboardTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/billboards", Forem::Billboard.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/billboards", status: 200, body: '[{"id":1,"name":"Banner One"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Billboard.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::Billboard, result.data[0]
    assert_equal "Banner One", result.data[0].name
  end

  def test_create
    mock_http, _ = stub_http_request(method: :post, path: "/api/billboards", status: 201, body: '{"id":1,"name":"New Banner"}')
    requestor = make_requestor(mock_http)
    result = Forem::Billboard.create({ name: "New Banner" }, requestor: requestor)
    assert_instance_of Forem::Billboard, result
    assert_equal "New Banner", result.name
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/billboards/1", status: 200, body: '{"id":1,"name":"Found"}')
    requestor = make_requestor(mock_http)
    result = Forem::Billboard.retrieve(1, requestor: requestor)
    assert_instance_of Forem::Billboard, result
    assert_equal "Found", result.name
  end

  def test_update
    mock_http, _ = stub_http_request(method: :put, path: "/api/billboards/1", status: 200, body: '{"id":1,"name":"Updated"}')
    requestor = make_requestor(mock_http)
    result = Forem::Billboard.update(1, { name: "Updated" }, requestor: requestor)
    assert_instance_of Forem::Billboard, result
    assert_equal "Updated", result.name
  end

  def test_unpublish
    mock_http, captured = stub_http_request(method: :put, path: "/api/billboards/1/unpublish", status: 204, body: "")
    requestor = make_requestor(mock_http)
    billboard = Forem::Billboard.construct_from({"id" => 1})
    result = billboard.unpublish(requestor: requestor)
    assert_equal 204, result.http_status
    assert_equal "PUT", captured[:method]
    assert_equal "/api/billboards/1/unpublish", captured[:path]
  end
end
