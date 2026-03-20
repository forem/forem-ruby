require "test_helper"

class Forem::ProfileImageTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/profile_images", Forem::ProfileImage.resource_path
  end

  def test_retrieve
    mock_http, captured = stub_http_request(method: :get, path: "/api/profile_images/alice", status: 200, body: '{"profile_image":"https://example.com/alice.jpg","profile_image_90":"https://example.com/alice_90.jpg"}')
    requestor = make_requestor(mock_http)
    result = Forem::ProfileImage.retrieve("alice", requestor: requestor)
    assert_instance_of Forem::ProfileImage, result
    assert_equal "https://example.com/alice.jpg", result.profile_image
    assert_equal "/api/profile_images/alice", captured[:path]
  end

  def test_retrieve_escapes_username
    mock_http, captured = stub_http_request(method: :get, path: "/api/profile_images/hello+world", status: 200, body: '{"profile_image":"https://example.com/hw.jpg"}')
    requestor = make_requestor(mock_http)
    Forem::ProfileImage.retrieve("hello world", requestor: requestor)
    assert_equal "/api/profile_images/hello+world", captured[:path]
  end
end
