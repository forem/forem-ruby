require "test_helper"

class Forem::TrendServiceTest < Minitest::Test
  include StubRequestHelper

  def test_list_gets_trends
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/trends", status: 200,
      body: '[{"id":1,"name":"AI Agents","slug":"ai-agents","score":42.5}]'
    )
    client = client_with_http(mock_http)

    result = client.trends.list(per_page: 5)

    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Trend, result.data[0]
    assert_equal "AI Agents", result.data[0].name
    assert_equal "GET", captured[:method]
    assert_equal "/api/trends", captured[:path].split("?").first
    assert_includes captured[:path], "per_page=5"
  end

  def test_retrieve_by_numeric_id
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/trends/1", status: 200,
      body: '{"id":1,"name":"AI Agents","slug":"ai-agents","description":"desc","score":42.5,"articles_count":12}'
    )
    client = client_with_http(mock_http)

    result = client.trends.retrieve(1)

    assert_instance_of Forem::Trend, result
    assert_equal 1, result.id
    assert_equal "AI Agents", result.name
    assert_equal "desc", result.description
    assert_equal 12, result.articles_count
    assert_equal "GET", captured[:method]
    assert_equal "/api/trends/1", captured[:path].split("?").first
  end

  def test_retrieve_by_slug
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/trends/ai-agents", status: 200,
      body: '{"id":1,"name":"AI Agents","slug":"ai-agents"}'
    )
    client = client_with_http(mock_http)

    result = client.trends.retrieve("ai-agents")

    assert_instance_of Forem::Trend, result
    assert_equal "ai-agents", result.slug
    assert_equal "/api/trends/ai-agents", captured[:path].split("?").first
  end

  def test_retrieve_includes_top_articles
    body = <<~JSON
      {
        "id": 1,
        "name": "AI Agents",
        "slug": "ai-agents",
        "top_articles": [
          {"id": 100, "title": "Intro to AI Agents", "slug": "intro-to-ai-agents", "score": 50, "published_at": "2026-02-01T00:00:00Z"}
        ]
      }
    JSON
    mock_http, = stub_http_request(method: :get, path: "/api/trends/1", status: 200, body: body)
    client = client_with_http(mock_http)

    result = client.trends.retrieve(1)

    assert_equal 1, result.top_articles.length
    assert_equal "Intro to AI Agents", result.top_articles[0]["title"]
    assert_equal "intro-to-ai-agents", result.top_articles[0]["slug"]
  end

  def test_articles_lists_articles_for_a_trend_by_id
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/trends/1/articles", status: 200,
      body: '[{"id":100,"title":"Intro to AI Agents","slug":"intro-to-ai-agents"}]'
    )
    client = client_with_http(mock_http)

    result = client.trends.articles(1)

    assert_instance_of Array, result
    assert_instance_of Forem::Article, result[0]
    assert_equal "Intro to AI Agents", result[0].title
    assert_equal "GET", captured[:method]
    assert_equal "/api/trends/1/articles", captured[:path].split("?").first
  end

  def test_articles_lists_articles_for_a_trend_by_slug_with_params
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/trends/ai-agents/articles", status: 200,
      body: '[{"id":100,"title":"A"},{"id":101,"title":"B"}]'
    )
    client = client_with_http(mock_http)

    result = client.trends.articles("ai-agents", per_page: 20, sort: "score", page: 2)

    assert_equal 2, result.length
    assert_equal ["A", "B"], result.map(&:title)
    assert_equal "/api/trends/ai-agents/articles", captured[:path].split("?").first
    assert_includes captured[:path], "per_page=20"
    assert_includes captured[:path], "sort=score"
    assert_includes captured[:path], "page=2"
  end

  def test_articles_returns_empty_array_when_trend_has_no_articles
    mock_http, = stub_http_request(method: :get, path: "/api/trends/1/articles", status: 200, body: "[]")
    client = client_with_http(mock_http)

    result = client.trends.articles(1)

    assert_equal [], result
  end

  private

  def client_with_http(mock_http)
    client = Forem::Client.new("test-key")
    connection_manager = Minitest::Mock.new
    connection_manager.expect(:connection_for, mock_http, [URI], open_timeout: Integer, read_timeout: Integer)
    client.requestor.instance_variable_set(:@connection_manager, connection_manager)
    client
  end
end
