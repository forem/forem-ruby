require "test_helper"

class Forem::AdminConceptTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/admin/concepts", Forem::AdminConcept.resource_path
  end

  def test_list
    body = '[{"id":1,"name":"Machine Learning","slug":"machine-learning","max_lookback_days":0}]'
    mock_http, captured = stub_http_request(method: :get, path: "/api/admin/concepts", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::AdminConcept.list({}, requestor: requestor)

    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::AdminConcept, result.data[0]
    assert_equal "Machine Learning", result.data[0].name
    assert_equal "machine-learning", result.data[0].slug
    assert_equal "GET", captured[:method]
    assert_equal "/api/admin/concepts", captured[:path]
  end

  def test_list_sends_pagination_query_params
    mock_http, captured = stub_http_request(method: :get, path: "/api/admin/concepts", status: 200, body: "[]")
    requestor = make_requestor(mock_http)

    result = Forem::AdminConcept.list({ page: 2, per_page: 100 }, requestor: requestor)

    assert_equal "/api/admin/concepts?page=2&per_page=100", captured[:path]
    assert_equal 2, result.current_page
    assert_equal 100, result.per_page
  end

  def test_retrieve
    body = '{"id":1,"name":"Machine Learning","description":"ML posts","similarity_threshold":0.8,"score":1.5}'
    mock_http, captured = stub_http_request(method: :get, path: "/api/admin/concepts/1", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::AdminConcept.retrieve(1, requestor: requestor)

    assert_instance_of Forem::AdminConcept, result
    assert_equal "Machine Learning", result.name
    assert_equal 0.8, result.similarity_threshold
    assert_equal "GET", captured[:method]
    assert_equal "/api/admin/concepts/1", captured[:path]
  end

  def test_create_wraps_params_in_a_concept_object
    body = '{"id":1,"name":"Machine Learning","slug":"machine-learning"}'
    mock_http, captured = stub_http_request(method: :post, path: "/api/admin/concepts", status: 201, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::AdminConcept.create(
      { name: "Machine Learning", description: "ML posts", similarity_threshold: 0.8 },
      requestor: requestor
    )

    assert_instance_of Forem::AdminConcept, result
    assert_equal "Machine Learning", result.name
    assert_equal "POST", captured[:method]
    assert_equal "/api/admin/concepts", captured[:path]
    assert_equal(
      {
        "concept" => {
          "name" => "Machine Learning",
          "description" => "ML posts",
          "similarity_threshold" => 0.8
        }
      },
      JSON.parse(captured[:body])
    )
  end

  def test_create_passes_through_already_wrapped_params
    mock_http, captured = stub_http_request(method: :post, path: "/api/admin/concepts", status: 201, body: '{"id":1}')
    requestor = make_requestor(mock_http)

    Forem::AdminConcept.create({ concept: { name: "Rust" } }, requestor: requestor)

    assert_equal({ "concept" => { "name" => "Rust" } }, JSON.parse(captured[:body]))
  end

  def test_create_raises_invalid_request_error_on_422
    mock_http, = stub_http_request(
      method: :post,
      path: "/api/admin/concepts",
      status: 422,
      body: '{"errors":["Name can\'t be blank"]}'
    )
    requestor = make_requestor(mock_http)

    error = assert_raises(Forem::InvalidRequestError) do
      Forem::AdminConcept.create({ name: "" }, requestor: requestor)
    end
    assert_equal "Name can't be blank", error.message
  end

  def test_update_wraps_params_in_a_concept_object
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/admin/concepts/1",
      status: 200,
      body: '{"id":1,"name":"Updated Concept"}'
    )
    requestor = make_requestor(mock_http)

    result = Forem::AdminConcept.update(1, { name: "Updated Concept", parent_id: 4 }, requestor: requestor)

    assert_instance_of Forem::AdminConcept, result
    assert_equal "Updated Concept", result.name
    assert_equal "PUT", captured[:method]
    assert_equal "/api/admin/concepts/1", captured[:path]
    assert_equal(
      { "concept" => { "name" => "Updated Concept", "parent_id" => 4 } },
      JSON.parse(captured[:body])
    )
  end

  def test_delete_returns_nil_for_the_empty_204_response
    mock_http, captured = stub_http_request(method: :delete, path: "/api/admin/concepts/1", status: 204, body: "")
    requestor = make_requestor(mock_http)

    assert_nil Forem::AdminConcept.delete(1, requestor: requestor)
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/admin/concepts/1", captured[:path]
  end

  def test_trigger_lookback_posts_days_to_the_member_path
    mock_http, captured = stub_http_request(
      method: :post,
      path: "/api/admin/concepts/1/trigger_lookback",
      status: 200,
      body: '{"message":"Lookback triggered for 40 days"}'
    )
    requestor = make_requestor(mock_http)

    result = Forem::AdminConcept.trigger_lookback(1, { days: 40 }, requestor: requestor)

    assert_instance_of Forem::ForemObject, result
    assert_equal "Lookback triggered for 40 days", result.message
    assert_equal "POST", captured[:method]
    assert_equal "/api/admin/concepts/1/trigger_lookback", captured[:path]
    assert_equal({ "days" => 40 }, JSON.parse(captured[:body]))
  end

  def test_instance_trigger_lookback_uses_the_resource_url
    mock_http, captured = stub_http_request(
      method: :post,
      path: "/api/admin/concepts/9/trigger_lookback",
      status: 200,
      body: '{"message":"Lookback triggered for 90 days"}'
    )
    requestor = make_requestor(mock_http)
    concept = Forem::AdminConcept.construct_from({ "id" => 9 })

    result = concept.trigger_lookback(90, requestor: requestor)

    assert_equal "Lookback triggered for 90 days", result.message
    assert_equal "POST", captured[:method]
    assert_equal "/api/admin/concepts/9/trigger_lookback", captured[:path]
    assert_equal({ "days" => 90 }, JSON.parse(captured[:body]))
  end

  def test_trigger_lookback_raises_invalid_request_error_on_422
    mock_http, = stub_http_request(
      method: :post,
      path: "/api/admin/concepts/1/trigger_lookback",
      status: 422,
      body: '{"error":"Invalid number of days"}'
    )
    requestor = make_requestor(mock_http)

    error = assert_raises(Forem::InvalidRequestError) do
      Forem::AdminConcept.trigger_lookback(1, { days: -10 }, requestor: requestor)
    end
    assert_equal "Invalid number of days", error.message
  end
end
