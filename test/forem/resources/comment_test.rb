require "test_helper"

class Forem::CommentTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/comments", Forem::Comment.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/comments", status: 200, body: '[{"id_code":"abc","body_html":"<p>Hello</p>"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Comment.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Comment, result.data[0]
    assert_equal "abc", result.data[0].id_code
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/comments/1", status: 200, body: '{"id_code":"abc","body_html":"<p>Hi</p>"}')
    requestor = make_requestor(mock_http)
    result = Forem::Comment.retrieve(1, requestor: requestor)
    assert_instance_of Forem::Comment, result
    assert_equal "abc", result.id_code
  end
end
