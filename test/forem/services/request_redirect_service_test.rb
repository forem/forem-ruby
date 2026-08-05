require "test_helper"

class Forem::RequestRedirectServiceTest < Minitest::Test
  include StubRequestHelper

  def test_list_gets_collection_and_returns_a_list_object
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/admin/request_redirects",
      status: 200,
      body: '[{"id":1,"original_url":"/old","destination_url":"http://new","request_domain":"example.com"}]'
    )
    client = client_with_http(mock_http)

    result = client.request_redirects.list(per_page: 25)

    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::RequestRedirect, result.data[0]
    assert_equal "/old", result.data[0].original_url
    assert_equal "GET", captured[:method]
    assert_equal "/api/admin/request_redirects?per_page=25", captured[:path]
  end

  def test_retrieve_gets_a_single_redirect
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/admin/request_redirects/7",
      status: 200,
      body: '{"id":7,"original_url":"/old","destination_url":"http://new","request_domain":"example.com"}'
    )
    client = client_with_http(mock_http)

    result = client.request_redirects.retrieve(7)

    assert_instance_of Forem::RequestRedirect, result
    assert_equal 7, result.id
    assert_equal "GET", captured[:method]
    assert_equal "/api/admin/request_redirects/7", captured[:path]
  end

  def test_create_wraps_flat_params_in_request_redirect_key
    mock_http, captured = stub_http_request(
      method: :post,
      path: "/api/admin/request_redirects",
      status: 201,
      body: '{"id":1,"original_url":"/old","destination_url":"http://new","request_domain":"example.com"}'
    )
    client = client_with_http(mock_http)

    result = client.request_redirects.create(
      original_url: "/old",
      destination_url: "http://new",
      request_domain: "example.com"
    )

    assert_instance_of Forem::RequestRedirect, result
    assert_equal "/old", result.original_url
    assert_equal "POST", captured[:method]
    assert_equal "/api/admin/request_redirects", captured[:path]
    assert_equal(
      {
        "request_redirect" => {
          "original_url" => "/old",
          "destination_url" => "http://new",
          "request_domain" => "example.com"
        }
      },
      JSON.parse(captured[:body])
    )
  end

  def test_update_wraps_flat_params_in_request_redirect_key
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/admin/request_redirects/7",
      status: 200,
      body: '{"id":7,"original_url":"/new-old","destination_url":"http://new","request_domain":"example.com"}'
    )
    client = client_with_http(mock_http)

    result = client.request_redirects.update(7, original_url: "/new-old")

    assert_instance_of Forem::RequestRedirect, result
    assert_equal "/new-old", result.original_url
    assert_equal "PUT", captured[:method]
    assert_equal "/api/admin/request_redirects/7", captured[:path]
    assert_equal({ "request_redirect" => { "original_url" => "/new-old" } }, JSON.parse(captured[:body]))
  end

  def test_delete_removes_a_redirect_and_returns_nil_for_empty_response
    mock_http, captured = stub_http_request(
      method: :delete,
      path: "/api/admin/request_redirects/7",
      status: 204,
      body: ""
    )
    client = client_with_http(mock_http)

    result = client.request_redirects.delete(7)

    assert_nil result
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/admin/request_redirects/7", captured[:path]
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
