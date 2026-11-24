require "test_helper"

class Forem::SubforemTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/subforems", Forem::Subforem.resource_path
  end

  def test_list
    body = '[{"id":1,"domain":"dev.to","root":true,"name":"DEV Community"}]'
    mock_http, captured = stub_http_request(method: :get, path: "/api/subforems", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::Subforem.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.length
    assert_instance_of Forem::Subforem, result[0]
    assert_equal "dev.to", result[0].domain
    assert_equal true, result[0].root
    assert_equal "GET", captured[:method]
    assert_equal "/api/subforems", captured[:path].split("?").first
  end
end
