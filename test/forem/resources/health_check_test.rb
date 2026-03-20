require "test_helper"

class Forem::HealthCheckTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/health_checks", Forem::HealthCheck.resource_path
  end

  def test_app
    mock_http, captured = stub_http_request(method: :get, path: "/api/health_checks/app", status: 200, body: '{"status":"OK"}')
    requestor = make_requestor(mock_http)
    result = Forem::HealthCheck.app(requestor: requestor)
    assert_instance_of Forem::ForemObject, result
    assert_equal "OK", result.status
    assert_equal "GET", captured[:method]
    assert_equal "/api/health_checks/app", captured[:path]
  end

  def test_database
    mock_http, captured = stub_http_request(method: :get, path: "/api/health_checks/database", status: 200, body: '{"status":"OK"}')
    requestor = make_requestor(mock_http)
    result = Forem::HealthCheck.database(requestor: requestor)
    assert_instance_of Forem::ForemObject, result
    assert_equal "OK", result.status
    assert_equal "GET", captured[:method]
    assert_equal "/api/health_checks/database", captured[:path]
  end

  def test_cache
    mock_http, captured = stub_http_request(method: :get, path: "/api/health_checks/cache", status: 200, body: '{"status":"OK"}')
    requestor = make_requestor(mock_http)
    result = Forem::HealthCheck.cache(requestor: requestor)
    assert_instance_of Forem::ForemObject, result
    assert_equal "OK", result.status
    assert_equal "GET", captured[:method]
    assert_equal "/api/health_checks/cache", captured[:path]
  end
end
