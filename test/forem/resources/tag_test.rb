require "test_helper"

class Forem::TagTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/tags", Forem::Tag.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/tags", status: 200, body: '[{"id":1,"name":"ruby"},{"id":2,"name":"rails"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Tag.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 2, result.data.length
    assert_instance_of Forem::Tag, result.data[0]
    assert_equal "ruby", result.data[0].name
  end
end
