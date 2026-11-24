require "test_helper"

class Forem::InstanceTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/instance", Forem::Instance.resource_path
  end

  def test_retrieve
    body = '{"name":"DEV Community","domain":"dev.to","visibility":"public","version":"2026.11"}'
    mock_http, captured = stub_http_request(method: :get, path: "/api/instance", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::Instance.retrieve(requestor: requestor)
    assert_instance_of Forem::Instance, result
    assert_equal "DEV Community", result.name
    assert_equal "dev.to", result.domain
    assert_equal "public", result.visibility
    assert_equal "GET", captured[:method]
    assert_equal "/api/instance", captured[:path]
  end
end
