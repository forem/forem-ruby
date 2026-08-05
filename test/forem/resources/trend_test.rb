require "test_helper"

class Forem::TrendTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/trends", Forem::Trend.resource_path
  end

  def test_list
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/trends", status: 200,
      body: '[{"id":1,"name":"AI Agents","slug":"ai-agents","type_of":"trend","score":42.5,"articles_count":12}]'
    )
    requestor = make_requestor(mock_http)
    result = Forem::Trend.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Trend, result.data[0]
    assert_equal "AI Agents", result.data[0].name
    assert_equal "ai-agents", result.data[0].slug
    assert_equal 42.5, result.data[0].score
    assert_equal "GET", captured[:method]
    assert_equal "/api/trends", captured[:path].split("?").first
  end

  def test_retrieve_by_numeric_id
    body = <<~JSON
      {
        "type_of": "trend",
        "id": 1,
        "name": "AI Agents",
        "slug": "ai-agents",
        "description": "Content about autonomous AI agents.",
        "key_questions": ["What are AI agents?"],
        "score": 42.5,
        "articles_count": 12,
        "cover_image": "https://example.com/cover.png",
        "first_observed_at": "2026-01-01T00:00:00Z",
        "last_observed_at": "2026-08-01T00:00:00Z",
        "created_at": "2026-01-01T00:00:00Z",
        "updated_at": "2026-08-01T00:00:00Z",
        "top_articles": [
          {"id": 100, "title": "Intro to AI Agents", "slug": "intro-to-ai-agents", "score": 50, "published_at": "2026-02-01T00:00:00Z"}
        ]
      }
    JSON
    mock_http, captured = stub_http_request(method: :get, path: "/api/trends/1", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::Trend.retrieve(1, requestor: requestor)

    assert_instance_of Forem::Trend, result
    assert_equal 1, result.id
    assert_equal "AI Agents", result.name
    assert_equal "ai-agents", result.slug
    assert_equal "Content about autonomous AI agents.", result.description
    assert_equal ["What are AI agents?"], result.key_questions
    assert_equal 42.5, result.score
    assert_equal 12, result.articles_count
    assert_equal "https://example.com/cover.png", result.cover_image
    assert_equal "2026-01-01T00:00:00Z", result.first_observed_at
    assert_equal "2026-08-01T00:00:00Z", result.last_observed_at
    assert_equal 1, result.top_articles.length
    assert_equal "Intro to AI Agents", result.top_articles[0]["title"]
    assert_equal "GET", captured[:method]
    assert_equal "/api/trends/1", captured[:path].split("?").first
  end

  def test_retrieve_by_slug
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/trends/ai-agents", status: 200,
      body: '{"id":1,"name":"AI Agents","slug":"ai-agents"}'
    )
    requestor = make_requestor(mock_http)

    result = Forem::Trend.retrieve("ai-agents", requestor: requestor)

    assert_instance_of Forem::Trend, result
    assert_equal "ai-agents", result.slug
    assert_equal "/api/trends/ai-agents", captured[:path].split("?").first
  end

  def test_articles_by_id
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/trends/1/articles", status: 200,
      body: '[{"id":100,"title":"Intro to AI Agents","slug":"intro-to-ai-agents","tag_list":["ai"],"tags":"ai"}]'
    )
    requestor = make_requestor(mock_http)

    result = Forem::Trend.articles(1, {}, requestor: requestor)

    assert_instance_of Array, result
    assert_instance_of Forem::Article, result[0]
    assert_equal "Intro to AI Agents", result[0].title
    assert_equal "GET", captured[:method]
    assert_equal "/api/trends/1/articles", captured[:path].split("?").first
  end

  def test_articles_by_slug_with_query_params
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/trends/ai-agents/articles", status: 200,
      body: '[{"id":100,"title":"Intro to AI Agents"},{"id":101,"title":"Advanced AI Agents"}]'
    )
    requestor = make_requestor(mock_http)

    result = Forem::Trend.articles("ai-agents", { per_page: 5, sort: "score" }, requestor: requestor)

    assert_equal 2, result.length
    assert_instance_of Forem::Article, result[1]
    assert_equal "Advanced AI Agents", result[1].title
    assert_equal "/api/trends/ai-agents/articles", captured[:path].split("?").first
    assert_includes captured[:path], "per_page=5"
    assert_includes captured[:path], "sort=score"
  end

  def test_articles_returns_empty_array_when_no_articles
    mock_http, = stub_http_request(method: :get, path: "/api/trends/1/articles", status: 200, body: "[]")
    requestor = make_requestor(mock_http)

    result = Forem::Trend.articles(1, {}, requestor: requestor)

    assert_equal [], result
  end
end
