require "test_helper"

class Forem::ConceptServiceTest < Minitest::Test
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

  def test_list_gets_concepts_with_pagination_and_days_params
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts",
      status: 200,
      body: "[#{CONCEPT_WITH_METRICS}]"
    )
    client = client_with_http(mock_http)

    result = client.concepts.list(page: 2, per_page: 100, days: 30)

    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Concept, result.data[0]
    assert_equal "Databases", result.data[0].name
    assert_equal "GET", captured[:method]
    assert_equal "/api/concepts?page=2&per_page=100&days=30", captured[:path]
  end

  def test_list_parses_nested_daily_metrics
    mock_http, = stub_http_request(
      method: :get,
      path: "/api/concepts",
      status: 200,
      body: "[#{CONCEPT_WITH_METRICS}]"
    )
    client = client_with_http(mock_http)

    concept = client.concepts.list.data[0]

    assert_equal 1, concept.daily_metrics.length
    assert_equal "2026-08-02", concept.daily_metrics[0].date
    assert_equal 3, concept.daily_metrics[0].articles_count
    assert_equal 9, concept.daily_metrics[0].comments_count
    assert_equal 120, concept.daily_metrics[0].page_views
    assert_equal 14, concept.daily_metrics[0].reactions_count
    assert_equal 6.5, concept.daily_metrics[0].popularity_score
  end

  def test_retrieve_gets_a_single_concept
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts/7",
      status: 200,
      body: CONCEPT_WITH_METRICS
    )
    client = client_with_http(mock_http)

    concept = client.concepts.retrieve(7)

    assert_instance_of Forem::Concept, concept
    assert_equal 7, concept.id
    assert_equal "databases", concept.slug
    assert_equal 1, concept.top_articles.length
    assert_equal "Indexes explained", concept.top_articles[0].title
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
    client = client_with_http(mock_http)

    client.concepts.retrieve(7, days: 14)

    assert_equal "/api/concepts/7?days=14", captured[:path]
  end

  def test_update_puts_params_wrapped_in_concept_key
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/concepts/7",
      status: 200,
      body: CONCEPT_WITH_METRICS
    )
    client = client_with_http(mock_http)

    concept = client.concepts.update(
      7,
      score: 4.5,
      description: "Storage engines and query planners",
      similarity_threshold: 0.8
    )

    assert_instance_of Forem::Concept, concept
    assert_equal 4.5, concept.score
    assert_equal 0.8, concept.similarity_threshold
    assert_equal 1, concept.daily_metrics.length
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

  def test_update_accepts_an_api_key_override
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/concepts/7",
      status: 200,
      body: CONCEPT_WITH_METRICS
    )
    client = client_with_http(mock_http)

    client.concepts.update(7, { description: "Updated" }, api_key: "override-key")

    assert_equal "override-key", captured[:headers]["api-key"]
    assert_equal({ "concept" => { "description" => "Updated" } }, JSON.parse(captured[:body]))
  end

  def test_articles_gets_articles_for_a_concept
    body = <<~JSON
      [
        {"id":11,"title":"Indexes explained","slug":"indexes-explained","positive_reactions_count":12},
        {"id":12,"title":"Query planners","slug":"query-planners","positive_reactions_count":4}
      ]
    JSON
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts/7/articles",
      status: 200,
      body: body
    )
    client = client_with_http(mock_http)

    result = client.concepts.articles(7)

    assert_instance_of Forem::ListObject, result
    assert_equal 2, result.data.length
    assert_instance_of Forem::Article, result.data[0]
    assert_equal "Indexes explained", result.data[0].title
    assert_equal 4, result.data[1].positive_reactions_count
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
    client = client_with_http(mock_http)

    result = client.concepts.articles(7, sort: "score", page: 3, per_page: 25)

    assert_equal [], result.data
    assert_equal "/api/concepts/7/articles?sort=score&page=3&per_page=25", captured[:path]
  end

  def test_search_gets_semantic_matches_with_distance_and_similarity
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
        },
        {
          "id": 9,
          "name": "Caching",
          "slug": "caching",
          "description": "Caches",
          "parent_id": 7,
          "score": 2.0,
          "similarity_threshold": null,
          "created_at": "2026-07-02T12:00:00Z",
          "updated_at": "2026-08-01T12:00:00Z",
          "distance": 0.4,
          "similarity": 0.6
        }
      ]
    JSON
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/concepts/search",
      status: 200,
      body: body
    )
    client = client_with_http(mock_http)

    result = client.concepts.search(q: "vector databases", per_page: 5, threshold: 0.5)

    assert_instance_of Array, result
    assert_equal 2, result.length
    assert_instance_of Forem::Concept, result[0]
    assert_equal "Databases", result[0].name
    assert_equal 0.12, result[0].distance
    assert_equal 0.88, result[0].similarity
    assert_equal 7, result[1].parent_id
    assert_nil result[1].similarity_threshold
    assert_equal "GET", captured[:method]
    assert_equal "/api/concepts/search?q=vector+databases&per_page=5&threshold=0.5", captured[:path]
  end

  def test_search_raises_on_a_missing_query_parameter
    mock_http, = stub_http_request(
      method: :get,
      path: "/api/concepts/search",
      status: 400,
      body: '{"error":"q parameter is required"}'
    )
    client = client_with_http(mock_http)

    error = assert_raises(Forem::APIError) { client.concepts.search }
    assert_equal 400, error.http_status
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
