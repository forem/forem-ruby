require "test_helper"

class Forem::AgentSessionTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/agent_sessions", Forem::AgentSession.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/agent_sessions", status: 200, body: '[{"id":1,"name":"Session A"}]')
    requestor = make_requestor(mock_http)
    result = Forem::AgentSession.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::AgentSession, result.data[0]
    assert_equal "Session A", result.data[0].name
  end

  def test_create
    mock_http, _ = stub_http_request(method: :post, path: "/api/agent_sessions", status: 201, body: '{"id":1,"name":"New Session"}')
    requestor = make_requestor(mock_http)
    result = Forem::AgentSession.create({ name: "New Session" }, requestor: requestor)
    assert_instance_of Forem::AgentSession, result
    assert_equal "New Session", result.name
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/agent_sessions/1", status: 200, body: '{"id":1,"name":"Found"}')
    requestor = make_requestor(mock_http)
    result = Forem::AgentSession.retrieve(1, requestor: requestor)
    assert_instance_of Forem::AgentSession, result
    assert_equal "Found", result.name
  end

  def test_presign
    mock_http, captured = stub_http_request(method: :post, path: "/api/agent_sessions/presign", status: 200, body: '{"url":"https://example.com/presigned"}')
    requestor = make_requestor(mock_http)
    result = Forem::AgentSession.presign({ filename: "test.txt" }, requestor: requestor)
    assert_instance_of Forem::ForemObject, result
    assert_equal "https://example.com/presigned", result.url
    assert_equal "POST", captured[:method]
    assert_equal "/api/agent_sessions/presign", captured[:path]
  end

  def test_raw_url
    mock_http, captured = stub_http_request(method: :get, path: "/api/agent_sessions/1/raw_url", status: 200, body: '{"raw_url":"https://example.com/raw"}')
    requestor = make_requestor(mock_http)
    session = Forem::AgentSession.construct_from({"id" => 1})
    result = session.raw_url(requestor: requestor)
    assert_instance_of Forem::ForemObject, result
    assert_equal "https://example.com/raw", result.raw_url
    assert_equal "GET", captured[:method]
    assert_equal "/api/agent_sessions/1/raw_url", captured[:path].split("?").first
  end
end
