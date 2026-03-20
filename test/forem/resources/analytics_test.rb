require "test_helper"

class Forem::AnalyticsTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/analytics", Forem::Analytics.resource_path
  end

  def test_totals
    mock_http, captured = stub_http_request(method: :get, path: "/api/analytics/totals", status: 200, body: '{"page_views":1000,"reactions":50}')
    requestor = make_requestor(mock_http)
    result = Forem::Analytics.totals({}, requestor: requestor)
    assert_instance_of Forem::ForemObject, result
    assert_equal 1000, result.page_views
    assert_equal 50, result.reactions
    assert_equal "GET", captured[:method]
    assert_equal "/api/analytics/totals", captured[:path].split("?").first
  end

  def test_historical
    mock_http, captured = stub_http_request(method: :get, path: "/api/analytics/historical", status: 200, body: '[{"date":"2024-01-01","page_views":100},{"date":"2024-01-02","page_views":200}]')
    requestor = make_requestor(mock_http)
    result = Forem::Analytics.historical({}, requestor: requestor)
    assert_instance_of Array, result
    assert_equal 2, result.length
    assert_instance_of Forem::ForemObject, result[0]
    assert_equal "2024-01-01", result[0].date
    assert_equal "GET", captured[:method]
    assert_equal "/api/analytics/historical", captured[:path].split("?").first
  end

  def test_past_day
    mock_http, captured = stub_http_request(method: :get, path: "/api/analytics/past_day", status: 200, body: '{"page_views":500,"reactions":25}')
    requestor = make_requestor(mock_http)
    result = Forem::Analytics.past_day({}, requestor: requestor)
    assert_instance_of Forem::ForemObject, result
    assert_equal 500, result.page_views
    assert_equal "GET", captured[:method]
    assert_equal "/api/analytics/past_day", captured[:path].split("?").first
  end

  def test_referrers
    mock_http, captured = stub_http_request(method: :get, path: "/api/analytics/referrers", status: 200, body: '[{"domain":"google.com","count":300},{"domain":"twitter.com","count":150}]')
    requestor = make_requestor(mock_http)
    result = Forem::Analytics.referrers({}, requestor: requestor)
    assert_instance_of Array, result
    assert_equal 2, result.length
    assert_instance_of Forem::ForemObject, result[0]
    assert_equal "google.com", result[0].domain
    assert_equal "GET", captured[:method]
    assert_equal "/api/analytics/referrers", captured[:path].split("?").first
  end
end
