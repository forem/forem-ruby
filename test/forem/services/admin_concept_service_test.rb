require "test_helper"

class Forem::AdminConceptServiceTest < Minitest::Test
  include StubRequestHelper

  def test_list_gets_concepts_and_wraps_them_in_a_list_object
    body = <<~JSON
      [
        {"id":1,"name":"Machine Learning","slug":"machine-learning","max_lookback_days":0},
        {"id":2,"name":"Ruby","slug":"ruby","max_lookback_days":30}
      ]
    JSON
    mock_http, captured = stub_http_request(method: :get, path: "/api/admin/concepts", status: 200, body: body)
    client = client_with_http(mock_http)

    result = client.admin_concepts.list(per_page: 100)

    assert_instance_of Forem::ListObject, result
    assert_equal 2, result.data.length
    assert_instance_of Forem::AdminConcept, result.data.first
    assert_equal "Machine Learning", result.data.first.name
    assert_equal 30, result.data.last.max_lookback_days
    assert_equal "GET", captured[:method]
    assert_equal "/api/admin/concepts?per_page=100", captured[:path]
    assert_equal "test-key", captured[:headers]["api-key"]
  end

  def test_retrieve_gets_a_single_concept
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/admin/concepts/7",
      status: 200,
      body: '{"id":7,"name":"Ruby","slug":"ruby","description":"Ruby posts","parent_id":null,' \
            '"similarity_threshold":0.75,"score":2.5,"max_lookback_days":30}'
    )
    client = client_with_http(mock_http)

    result = client.admin_concepts.retrieve(7)

    assert_instance_of Forem::AdminConcept, result
    assert_equal 7, result.id
    assert_equal "Ruby", result.name
    assert_equal "ruby", result.slug
    assert_nil result.parent_id
    assert_equal 0.75, result.similarity_threshold
    assert_equal 2.5, result.score
    assert_equal 30, result.max_lookback_days
    assert_equal "GET", captured[:method]
    assert_equal "/api/admin/concepts/7", captured[:path]
  end

  def test_create_posts_wrapped_params_and_returns_the_created_concept
    mock_http, captured = stub_http_request(
      method: :post,
      path: "/api/admin/concepts",
      status: 201,
      body: '{"id":7,"name":"Machine Learning","slug":"machine-learning","description":"ML posts",' \
            '"similarity_threshold":0.8,"max_lookback_days":0}'
    )
    client = client_with_http(mock_http)

    result = client.admin_concepts.create(
      name: "Machine Learning",
      description: "ML posts",
      parent_id: 3,
      similarity_threshold: 0.8,
      score: 1.0
    )

    assert_instance_of Forem::AdminConcept, result
    assert_equal 7, result.id
    assert_equal "machine-learning", result.slug
    assert_equal "POST", captured[:method]
    assert_equal "/api/admin/concepts", captured[:path]
    assert_equal(
      {
        "concept" => {
          "name" => "Machine Learning",
          "description" => "ML posts",
          "parent_id" => 3,
          "similarity_threshold" => 0.8,
          "score" => 1.0
        }
      },
      JSON.parse(captured[:body])
    )
  end

  def test_create_raises_on_validation_errors
    mock_http, = stub_http_request(
      method: :post,
      path: "/api/admin/concepts",
      status: 422,
      body: '{"errors":["Name can\'t be blank","Slug can\'t be blank"]}'
    )
    client = client_with_http(mock_http)

    error = assert_raises(Forem::InvalidRequestError) { client.admin_concepts.create(name: "") }
    assert_equal "Name can't be blank, Slug can't be blank", error.message
  end

  def test_update_puts_wrapped_params_and_returns_the_updated_concept
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/admin/concepts/7",
      status: 200,
      body: '{"id":7,"name":"Updated Concept","similarity_threshold":0.9}'
    )
    client = client_with_http(mock_http)

    result = client.admin_concepts.update(7, name: "Updated Concept", similarity_threshold: 0.9)

    assert_instance_of Forem::AdminConcept, result
    assert_equal "Updated Concept", result.name
    assert_equal 0.9, result.similarity_threshold
    assert_equal "PUT", captured[:method]
    assert_equal "/api/admin/concepts/7", captured[:path]
    assert_equal(
      { "concept" => { "name" => "Updated Concept", "similarity_threshold" => 0.9 } },
      JSON.parse(captured[:body])
    )
  end

  def test_delete_returns_nil_for_the_empty_no_content_response
    mock_http, captured = stub_http_request(method: :delete, path: "/api/admin/concepts/7", status: 204, body: "")
    client = client_with_http(mock_http)

    assert_nil client.admin_concepts.delete(7)
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/admin/concepts/7", captured[:path]
  end

  def test_delete_raises_not_found_for_a_missing_concept
    mock_http, = stub_http_request(
      method: :delete,
      path: "/api/admin/concepts/999",
      status: 404,
      body: '{"error":"Not Found"}'
    )
    client = client_with_http(mock_http)

    assert_raises(Forem::NotFoundError) { client.admin_concepts.delete(999) }
  end

  def test_trigger_lookback_posts_days_and_returns_the_message
    mock_http, captured = stub_http_request(
      method: :post,
      path: "/api/admin/concepts/7/trigger_lookback",
      status: 200,
      body: '{"message":"Lookback triggered for 90 days"}'
    )
    client = client_with_http(mock_http)

    result = client.admin_concepts.trigger_lookback(7, days: 90)

    assert_instance_of Forem::ForemObject, result
    assert_equal "Lookback triggered for 90 days", result.message
    assert_equal "POST", captured[:method]
    assert_equal "/api/admin/concepts/7/trigger_lookback", captured[:path]
    assert_equal({ "days" => 90 }, JSON.parse(captured[:body]))
  end

  def test_trigger_lookback_raises_when_days_is_rejected
    mock_http, = stub_http_request(
      method: :post,
      path: "/api/admin/concepts/7/trigger_lookback",
      status: 422,
      body: '{"error":"Days must be greater than the current lookback window"}'
    )
    client = client_with_http(mock_http)

    error = assert_raises(Forem::InvalidRequestError) { client.admin_concepts.trigger_lookback(7, days: 10) }
    assert_equal "Days must be greater than the current lookback window", error.message
  end

  def test_requests_accept_a_per_request_api_key_override
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/admin/concepts/7",
      status: 200,
      body: '{"id":7,"name":"Ruby"}'
    )
    client = client_with_http(mock_http)

    client.admin_concepts.retrieve(7, api_key: "override-key")

    assert_equal "override-key", captured[:headers]["api-key"]
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
