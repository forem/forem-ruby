require "test_helper"

class Forem::VideoTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/videos", Forem::Video.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/videos", status: 200, body: '[{"id":1,"title":"Video One"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Video.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::Video, result.data[0]
    assert_equal "Video One", result.data[0].title
  end
end
