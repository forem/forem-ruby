require "test_helper"

class CrudTestResource < Forem::APIResource
  extend Forem::APIOperations::Create
  extend Forem::APIOperations::List
  extend Forem::APIOperations::Retrieve
  extend Forem::APIOperations::Update
  include Forem::APIOperations::Delete
  include Forem::APIOperations::Save

  OBJECT_NAME = "crud_test"
  RESOURCE_PATH = "/api/crud_tests"
end

class Forem::APIOperationsTest < Minitest::Test
  include StubRequestHelper

  def test_create
    mock_http, captured = stub_http_request(method: :post, path: "/api/crud_tests", status: 201, body: '{"id":1,"name":"new"}')
    requestor = make_requestor(mock_http)
    result = CrudTestResource.create({ name: "new" }, { requestor: requestor })
    assert_instance_of CrudTestResource, result
    assert_equal 1, result.id
    assert_equal "new", result.name
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/crud_tests", status: 200, body: '[{"id":1},{"id":2}]')
    requestor = make_requestor(mock_http)
    result = CrudTestResource.list({ page: 1, per_page: 30 }, { requestor: requestor })
    assert_instance_of Forem::ListObject, result
    assert_equal 2, result.data.length
    assert_instance_of CrudTestResource, result.data[0]
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/crud_tests/1", status: 200, body: '{"id":1,"name":"found"}')
    requestor = make_requestor(mock_http)
    result = CrudTestResource.retrieve(1, requestor: requestor)
    assert_instance_of CrudTestResource, result
    assert_equal "found", result.name
  end

  def test_update
    mock_http, captured = stub_http_request(method: :put, path: "/api/crud_tests/1", status: 200, body: '{"id":1,"name":"updated"}')
    requestor = make_requestor(mock_http)
    result = CrudTestResource.update(1, { name: "updated" }, { requestor: requestor })
    assert_instance_of CrudTestResource, result
    assert_equal "updated", result.name
  end

  def test_delete_instance
    mock_http, _ = stub_http_request(method: :delete, path: "/api/crud_tests/1", status: 200, body: '{"id":1}')
    requestor = make_requestor(mock_http)
    obj = CrudTestResource.construct_from({"id" => 1})
    result = obj.delete(requestor: requestor)
    assert_instance_of CrudTestResource, result
  end

  def test_delete_class_method
    mock_http, _ = stub_http_request(method: :delete, path: "/api/crud_tests/1", status: 200, body: '{"id":1}')
    requestor = make_requestor(mock_http)
    result = CrudTestResource.delete(1, requestor: requestor)
    assert_instance_of CrudTestResource, result
  end

  def test_save
    mock_http, captured = stub_http_request(method: :put, path: "/api/crud_tests/1", status: 200, body: '{"id":1,"name":"saved"}')
    requestor = make_requestor(mock_http)
    obj = CrudTestResource.construct_from({"id" => 1, "name" => "old"})
    result = obj.save({ name: "saved" }, requestor: requestor)
    assert_instance_of CrudTestResource, result
  end
end
