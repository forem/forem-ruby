require "test_helper"

class Forem::ReactionTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/reactions", Forem::Reaction.resource_path
  end

  def test_create
    mock_http, captured = stub_http_request(method: :post, path: "/api/reactions", status: 200, body: '{"result":"create","id":1}')
    requestor = make_requestor(mock_http)
    result = Forem::Reaction.create({ category: "like", reactable_id: 1, reactable_type: "Article" }, requestor: requestor)
    assert_instance_of Forem::Reaction, result
    assert_equal "POST", captured[:method]
    assert_equal "/api/reactions", captured[:path]
  end

  def test_toggle
    mock_http, captured = stub_http_request(method: :post, path: "/api/reactions/toggle", status: 200, body: '{"result":"create","id":1}')
    requestor = make_requestor(mock_http)
    result = Forem::Reaction.toggle({ category: "like", reactable_id: 1, reactable_type: "Article" }, requestor: requestor)
    assert_instance_of Forem::Reaction, result
    assert_equal "POST", captured[:method]
    assert_equal "/api/reactions/toggle", captured[:path]
  end
end
