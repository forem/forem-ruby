require "test_helper"

class Forem::ConceptTest < Minitest::Test
  include StubRequestHelper

  CONCEPT_WITH_METRICS = <<~JSON.freeze
    {
      "id": 7,
      "name": "Databases",
      "slug": "databases",
      "description": "Storage engines and query planners",
      "parent_id": null,
      "score": 4.5,
      "similarity_threshold": 0.8,
      "created_at": "2026-07-01T12:00:00Z",
      "updated_at": "2026-08-01T12:00:00Z",
      "daily_metrics": [
        {
          "date": "2026-08-02",
          "articles_count": 3,
          "comments_count": 9,
          "page_views": 120,
          "reactions_count": 14,
          "popularity_score": 6.5
        },
        {
          "date": "2026-08-01",
          "articles_count": 1,
          "comments_count": 2,
          "page_views": 40,
          "reactions_count": 3,
          "popularity_score": 1.5
        }
      ],
      "top_articles": [
        {
          "id": 11,
          "title": "Indexes explained",
          "slug": "indexes-explained",
          "score": 88.0,
          "published_at": "2026-07-20T09:00:00Z"
        }
      ]
    }
  JSON

  def test_resource_path
    assert_equal "/api/concepts", Forem::Concept.resource_path
  end

  def test_list
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts",
      status: 200,
      body: '[{"id":7,"name":"Databases","slug":"databases","daily_metrics":[]}]'
    )
    requestor = make_requestor(mock_http)

    result = Forem::Concept.list({}, requestor: requestor)

    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::Concept, result.data[0]
    assert_equal "Databases", result.data[0].name
    assert_equal "GET", captured[:method]
    assert_equal "/api/concepts", captured[:path]
  end

  def test_list_sends_pagination_and_days_query_params
    mock_http, captured = stub_http_request(method: :get, path: "/api/concepts", status: 200, body: "[]")
    requestor = make_requestor(mock_http)

    Forem::Concept.list({ page: 2, per_page: 100, days: 30 }, requestor: requestor)

    assert_equal "/api/concepts?page=2&per_page=100&days=30", captured[:path]
  end

  def test_list_parses_nested_daily_metrics
    mock_http, = stub_http_request(
      method: :get,
      path: "/api/concepts",
      status: 200,
      body: "[#{CONCEPT_WITH_METRICS}]"
    )
    requestor = make_requestor(mock_http)

    concept = Forem::Concept.list({}, requestor: requestor).data[0]

    assert_equal 2, concept.daily_metrics.length
    assert_equal "2026-08-02", concept.daily_metrics[0].date
    assert_equal 3, concept.daily_metrics[0].articles_count
    assert_equal 6.5, concept.daily_metrics[0].popularity_score
  end

  def test_retrieve
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts/7",
      status: 200,
      body: CONCEPT_WITH_METRICS
    )
    requestor = make_requestor(mock_http)

    result = Forem::Concept.retrieve(7, {}, requestor: requestor)

    assert_instance_of Forem::Concept, result
    assert_equal 7, result.id
    assert_equal "Databases", result.name
    assert_equal 0.8, result.similarity_threshold
    assert_equal "GET", captured[:method]
    assert_equal "/api/concepts/7", captured[:path]
  end

  def test_retrieve_sends_days_query_param
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts/7",
      status: 200,
      body: CONCEPT_WITH_METRICS
    )
    requestor = make_requestor(mock_http)

    Forem::Concept.retrieve(7, { days: 14 }, requestor: requestor)

    assert_equal "/api/concepts/7?days=14", captured[:path]
  end

  def test_retrieve_parses_nested_daily_metrics_and_top_articles
    mock_http, = stub_http_request(
      method: :get,
      path: "/api/concepts/7",
      status: 200,
      body: CONCEPT_WITH_METRICS
    )
    requestor = make_requestor(mock_http)

    concept = Forem::Concept.retrieve(7, {}, requestor: requestor)

    assert_equal 2, concept.daily_metrics.length
    assert_equal 120, concept.daily_metrics[0].page_views
    assert_equal "2026-08-01", concept.daily_metrics[1].date
    assert_equal 1, concept.top_articles.length
    assert_equal "Indexes explained", concept.top_articles[0].title
  end

  def test_update_wraps_flat_params_in_concept_key
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/concepts/7",
      status: 200,
      body: CONCEPT_WITH_METRICS
    )
    requestor = make_requestor(mock_http)

    result = Forem::Concept.update(
      7,
      { score: 4.5, description: "Storage engines and query planners", similarity_threshold: 0.8 },
      requestor: requestor
    )

    assert_instance_of Forem::Concept, result
    assert_equal 4.5, result.score
    assert_equal "PUT", captured[:method]
    assert_equal "/api/concepts/7", captured[:path]
    assert_equal(
      {
        "concept" => {
          "score" => 4.5,
          "description" => "Storage engines and query planners",
          "similarity_threshold" => 0.8
        }
      },
      JSON.parse(captured[:body])
    )
  end

  def test_update_passes_through_already_wrapped_params
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/concepts/7",
      status: 200,
      body: CONCEPT_WITH_METRICS
    )
    requestor = make_requestor(mock_http)

    Forem::Concept.update(7, { concept: { description: "Wrapped" } }, requestor: requestor)

    assert_equal({ "concept" => { "description" => "Wrapped" } }, JSON.parse(captured[:body]))
  end

  def test_articles_returns_article_list_object
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts/7/articles",
      status: 200,
      body: '[{"id":11,"title":"Indexes explained","slug":"indexes-explained"}]'
    )
    requestor = make_requestor(mock_http)

    result = Forem::Concept.articles(7, {}, requestor: requestor)

    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Article, result.data[0]
    assert_equal "Indexes explained", result.data[0].title
    assert_equal "GET", captured[:method]
    assert_equal "/api/concepts/7/articles", captured[:path]
  end

  def test_articles_sends_sort_and_pagination_query_params
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts/7/articles",
      status: 200,
      body: "[]"
    )
    requestor = make_requestor(mock_http)

    Forem::Concept.articles(7, { sort: "score", page: 3, per_page: 25 }, requestor: requestor)

    assert_equal "/api/concepts/7/articles?sort=score&page=3&per_page=25", captured[:path]
  end

  def test_search_returns_concepts_with_distance_and_similarity
    body = <<~JSON
      [
        {
          "id": 7,
          "name": "Databases",
          "slug": "databases",
          "description": "Storage engines",
          "parent_id": null,
          "score": 4.5,
          "similarity_threshold": 0.8,
          "created_at": "2026-07-01T12:00:00Z",
          "updated_at": "2026-08-01T12:00:00Z",
          "distance": 0.12,
          "similarity": 0.88
        }
      ]
    JSON
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts/search",
      status: 200,
      body: body
    )
    requestor = make_requestor(mock_http)

    result = Forem::Concept.search({ q: "databases" }, requestor: requestor)

    assert_instance_of Array, result
    assert_equal 1, result.length
    assert_instance_of Forem::Concept, result[0]
    assert_equal 0.12, result[0].distance
    assert_equal 0.88, result[0].similarity
    assert_equal "GET", captured[:method]
    assert_equal "/api/concepts/search?q=databases", captured[:path]
  end

  def test_search_sends_per_page_and_threshold_query_params
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts/search",
      status: 200,
      body: "[]"
    )
    requestor = make_requestor(mock_http)

    result = Forem::Concept.search({ q: "vector search", per_page: 5, threshold: 0.5 }, requestor: requestor)

    assert_equal [], result
    assert_equal "/api/concepts/search?q=vector+search&per_page=5&threshold=0.5", captured[:path]
  end
end
