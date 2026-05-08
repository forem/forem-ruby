require "test_helper"

class Forem::AnalyticsTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/analytics", Forem::Analytics.resource_path
  end

  def test_totals_returns_nested_stats_object
    body = <<~JSON
      {
        "comments":   {"total": 1},
        "follows":    {"total": 2},
        "reactions":  {"total": 7, "like": 2, "readinglist": 0, "unicorn": 5},
        "page_views": {"total": 7, "average_read_time_in_seconds": 15, "total_read_time_in_seconds": 105}
      }
    JSON
    mock_http, captured = stub_http_request(method: :get, path: "/api/analytics/totals", status: 200, body: body)
    requestor = make_requestor(mock_http)
    result = Forem::Analytics.totals({}, requestor: requestor)
    assert_instance_of Forem::ForemObject, result
    assert_equal 7, result.reactions.total
    assert_equal 2, result.reactions.like
    assert_equal 15, result.page_views.average_read_time_in_seconds
    assert_equal "/api/analytics/totals", captured[:path].split("?").first
  end

  def test_historical_returns_hash_keyed_by_date
    body = <<~JSON
      {
        "2024-01-01": { "page_views": {"total": 100}, "reactions": {"total": 0} },
        "2024-01-02": { "page_views": {"total": 200}, "reactions": {"total": 1} }
      }
    JSON
    mock_http, captured = stub_http_request(method: :get, path: "/api/analytics/historical", status: 200, body: body)
    requestor = make_requestor(mock_http)
    result = Forem::Analytics.historical({ start: "2024-01-01", end: "2024-01-02" }, requestor: requestor)
    assert_instance_of Hash, result
    assert_equal ["2024-01-01", "2024-01-02"], result.keys.sort
    assert_instance_of Forem::ForemObject, result["2024-01-01"]
    assert_equal 100, result["2024-01-01"].page_views.total
    assert_equal 1,   result["2024-01-02"].reactions.total
    assert_equal "/api/analytics/historical", captured[:path].split("?").first
  end

  def test_historical_handles_nil_day_values
    # The API emits null for some days; ensure we don't blow up.
    body = '{"2024-01-01": null, "2024-01-02": {"page_views": {"total": 5}}}'
    mock_http, _ = stub_http_request(method: :get, path: "/api/analytics/historical", status: 200, body: body)
    requestor = make_requestor(mock_http)
    result = Forem::Analytics.historical({ start: "2024-01-01" }, requestor: requestor)
    assert_instance_of Forem::ForemObject, result["2024-01-01"]
    assert_equal 5, result["2024-01-02"].page_views.total
  end

  def test_past_day_returns_hash_keyed_by_date
    body = <<~JSON
      {
        "2026-05-07": { "page_views": {"total": 0} },
        "2026-05-08": { "page_views": {"total": 3} }
      }
    JSON
    mock_http, captured = stub_http_request(method: :get, path: "/api/analytics/past_day", status: 200, body: body)
    requestor = make_requestor(mock_http)
    result = Forem::Analytics.past_day({}, requestor: requestor)
    assert_instance_of Hash, result
    assert_equal 3, result["2026-05-08"].page_views.total
    assert_equal "/api/analytics/past_day", captured[:path].split("?").first
  end

  def test_referrers_unwraps_domains_envelope
    body = '{"domains":[{"domain":"google.com","count":300},{"domain":"twitter.com","count":150}]}'
    mock_http, captured = stub_http_request(method: :get, path: "/api/analytics/referrers", status: 200, body: body)
    requestor = make_requestor(mock_http)
    result = Forem::Analytics.referrers({}, requestor: requestor)
    assert_instance_of Array, result
    assert_equal 2, result.length
    assert_instance_of Forem::ForemObject, result[0]
    assert_equal "google.com", result[0].domain
    assert_equal 300, result[0].count
    assert_equal "/api/analytics/referrers", captured[:path].split("?").first
  end

  def test_referrers_empty_domains
    mock_http, _ = stub_http_request(method: :get, path: "/api/analytics/referrers", status: 200, body: '{"domains":[]}')
    requestor = make_requestor(mock_http)
    result = Forem::Analytics.referrers({}, requestor: requestor)
    assert_equal [], result
  end
end
