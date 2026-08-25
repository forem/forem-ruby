require "test_helper"

class Forem::EventServiceTest < Minitest::Test
  include StubRequestHelper

  def test_list_gets_events
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/events",
      status: 200,
      body: '[{"id":1,"title":"HackRice","type_of":"challenge"}]'
    )
    client = client_with_http(mock_http)

    result = client.events.list

    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::Event, result.data[0]
    assert_equal "HackRice", result.data[0].title
    assert_equal "GET", captured[:method]
    assert_equal "/api/events", captured[:path]
  end

  def test_list_with_type_of_filter
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/events?type_of=challenge",
      status: 200,
      body: '[{"id":1,"title":"HackRice","type_of":"challenge"}]'
    )
    client = client_with_http(mock_http)

    result = client.events.list(type_of: "challenge")

    assert_instance_of Forem::ListObject, result
    assert_equal "challenge", result.data[0].type_of
    assert_equal "/api/events?type_of=challenge", captured[:path]
  end

  def test_retrieve_gets_event_by_id
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/events/10",
      status: 200,
      body: '{"id":10,"title":"Live Q&A","type_of":"live_stream","full_details":"Stream rundown"}'
    )
    client = client_with_http(mock_http)

    result = client.events.retrieve(10)

    assert_instance_of Forem::Event, result
    assert_equal 10, result.id
    assert_equal "Live Q&A", result.title
    assert_equal "Stream rundown", result.full_details
    assert_equal "/api/events/10", captured[:path]
  end

  def test_create_posts_event_and_wraps_params
    mock_http, captured = stub_http_request(
      method: :post,
      path: "/api/events",
      status: 201,
      body: '{"id":5,"title":"Community Meetup","event_name_slug":"meetup","event_variation_slug":"1","type_of":"other","full_details":"Meetup agenda"}'
    )
    client = client_with_http(mock_http)

    result = client.events.create(
      title: "Community Meetup",
      event_name_slug: "meetup",
      event_variation_slug: "1",
      start_time: "2026-09-01T12:00:00Z",
      end_time: "2026-09-01T14:00:00Z",
      type_of: "other",
      full_details: "Meetup agenda"
    )

    assert_instance_of Forem::Event, result
    assert_equal "Community Meetup", result.title
    assert_equal "Meetup agenda", result.full_details
    assert_equal "POST", captured[:method]
    assert_equal "/api/events", captured[:path]
    parsed = JSON.parse(captured[:body])
    assert_equal "Community Meetup", parsed.dig("event", "title")
    assert_equal "Meetup agenda", parsed.dig("event", "full_details")
  end

  def test_update_puts_event_and_wraps_params
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/events/5",
      status: 200,
      body: '{"id":5,"title":"Updated Meetup","full_details":"Updated agenda"}'
    )
    client = client_with_http(mock_http)

    result = client.events.update(5, title: "Updated Meetup", full_details: "Updated agenda")

    assert_instance_of Forem::Event, result
    assert_equal "Updated Meetup", result.title
    assert_equal "Updated agenda", result.full_details
    assert_equal "PUT", captured[:method]
    assert_equal "/api/events/5", captured[:path]
    parsed = JSON.parse(captured[:body])
    assert_equal "Updated Meetup", parsed.dig("event", "title")
    assert_equal "Updated agenda", parsed.dig("event", "full_details")
  end

  def test_delete_deletes_event
    mock_http, captured = stub_http_request(
      method: :delete,
      path: "/api/events/5",
      status: 204,
      body: ""
    )
    client = client_with_http(mock_http)

    result = client.events.delete(5)

    assert_nil result
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/events/5", captured[:path]
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
