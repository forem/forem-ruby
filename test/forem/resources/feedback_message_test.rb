require "test_helper"

class Forem::FeedbackMessageTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/feedback_messages", Forem::FeedbackMessage.resource_path
  end

  def test_update_wraps_flat_params
    body = '{"id":42,"status":"Resolved"}'
    mock_http, captured = stub_http_request(method: :put, path: "/api/feedback_messages/42", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::FeedbackMessage.update(42, { status: "Resolved" }, requestor: requestor)
    assert_instance_of Forem::FeedbackMessage, result
    assert_equal "Resolved", result.status
    assert_equal "PUT", captured[:method]
    assert_equal({ "feedback_message" => { "status" => "Resolved" } }, JSON.parse(captured[:body]))
  end

  def test_update_preserves_already_wrapped_params
    body = '{"id":42,"status":"Invalid"}'
    mock_http, captured = stub_http_request(method: :put, path: "/api/feedback_messages/42", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::FeedbackMessage.update(42, { feedback_message: { status: "Invalid" } }, requestor: requestor)
    assert_equal "Invalid", result.status
    assert_equal({ "feedback_message" => { "status" => "Invalid" } }, JSON.parse(captured[:body]))
  end
end
