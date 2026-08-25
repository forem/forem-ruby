require "test_helper"

class Forem::EventTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/events", Forem::Event.resource_path
  end

  def test_list
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/events",
      status: 200,
      body: '[{"id":1,"title":"Hackathon 2026","type_of":"challenge","full_details":"Full hackathon details"}]'
    )
    requestor = make_requestor(mock_http)
    result = Forem::Event.list({}, requestor: requestor)

    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::Event, result.data[0]
    assert_equal "Hackathon 2026", result.data[0].title
    assert_equal "challenge", result.data[0].type_of
    assert_equal "Full hackathon details", result.data[0].full_details
    assert_equal "GET", captured[:method]
    assert_equal "/api/events", captured[:path]
  end

  def test_list_with_type_of_filter
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/events?type_of=live_stream",
      status: 200,
      body: '[{"id":2,"title":"Live Stream","type_of":"live_stream"}]'
    )
    requestor = make_requestor(mock_http)
    result = Forem::Event.list({ type_of: "live_stream" }, requestor: requestor)

    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_equal "live_stream", result.data[0].type_of
    assert_equal "/api/events?type_of=live_stream", captured[:path]
  end

  def test_retrieve
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/events/12",
      status: 200,
      body: '{"id":12,"title":"Hackathon","type_of":"challenge","full_details":"Agenda and notes"}'
    )
    requestor = make_requestor(mock_http)
    result = Forem::Event.retrieve(12, requestor: requestor)

    assert_instance_of Forem::Event, result
    assert_equal 12, result.id
    assert_equal "Hackathon", result.title
    assert_equal "Agenda and notes", result.full_details
    assert_equal "/api/events/12", captured[:path]
  end

  def test_create_wraps_flat_params
    mock_http, captured = stub_http_request(
      method: :post,
      path: "/api/events",
      status: 201,
      body: '{"id":1,"title":"New Event","event_name_slug":"new-event","full_details":"Details"}'
    )
    requestor = make_requestor(mock_http)
    result = Forem::Event.create(
      {
        title: "New Event",
        event_name_slug: "new-event",
        event_variation_slug: "2026",
        start_time: "2026-09-01T00:00:00Z",
        end_time: "2026-09-02T00:00:00Z",
        full_details: "Details"
      },
      requestor: requestor
    )

    assert_instance_of Forem::Event, result
    assert_equal "New Event", result.title
    assert_equal "Details", result.full_details
    assert_equal "POST", captured[:method]
    assert_equal "/api/events", captured[:path]
    parsed_body = JSON.parse(captured[:body])
    assert parsed_body.key?("event")
    assert_equal "New Event", parsed_body["event"]["title"]
    assert_equal "Details", parsed_body["event"]["full_details"]
  end

  def test_update_wraps_flat_params
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/events/12",
      status: 200,
      body: '{"id":12,"title":"Updated Event","full_details":"Updated Details"}'
    )
    requestor = make_requestor(mock_http)
    result = Forem::Event.update(12, { title: "Updated Event", full_details: "Updated Details" }, requestor: requestor)

    assert_instance_of Forem::Event, result
    assert_equal "Updated Event", result.title
    assert_equal "Updated Details", result.full_details
    assert_equal "PUT", captured[:method]
    assert_equal "/api/events/12", captured[:path]
    parsed_body = JSON.parse(captured[:body])
    assert parsed_body.key?("event")
    assert_equal "Updated Event", parsed_body["event"]["title"]
    assert_equal "Updated Details", parsed_body["event"]["full_details"]
  end

  def test_delete_class_method
    mock_http, captured = stub_http_request(
      method: :delete,
      path: "/api/events/12",
      status: 204,
      body: ""
    )
    requestor = make_requestor(mock_http)
    result = Forem::Event.delete(12, requestor: requestor)

    assert_nil result
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/events/12", captured[:path]
  end

  def test_delete_instance_method
    mock_http, captured = stub_http_request(
      method: :delete,
      path: "/api/events/12",
      status: 204,
      body: ""
    )
    requestor = make_requestor(mock_http)
    event = Forem::Event.construct_from({ "id" => 12, "title" => "Event" })
    result = event.delete(requestor: requestor)

    assert_equal event, result
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/events/12", captured[:path]
  end

  def test_save_instance_method
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/events/12",
      status: 200,
      body: '{"id":12,"title":"Saved Event"}'
    )
    requestor = make_requestor(mock_http)
    event = Forem::Event.construct_from({ "id" => 12, "title" => "Original Event" })
    result = event.save({ title: "Saved Event" }, requestor: requestor)

    assert_instance_of Forem::Event, result
    assert_equal "Saved Event", result.title
    assert_equal "PUT", captured[:method]
    assert_equal "/api/events/12", captured[:path]
    parsed_body = JSON.parse(captured[:body])
    assert parsed_body.key?("event")
    assert_equal "Saved Event", parsed_body["event"]["title"]
  end
end
