require "test_helper"

class Forem::RequestRedirectTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/admin/request_redirects", Forem::RequestRedirect.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(
      method: :get,
      path: "/api/admin/request_redirects",
      status: 200,
      body: '[{"id":1,"original_url":"/old","destination_url":"http://new","request_domain":"example.com"}]'
    )
    requestor = make_requestor(mock_http)
    result = Forem::RequestRedirect.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::RequestRedirect, result.data[0]
    assert_equal "/old", result.data[0].original_url
  end

  def test_create
    mock_http, captured = stub_http_request(
      method: :post,
      path: "/api/admin/request_redirects",
      status: 201,
      body: '{"id":1,"original_url":"/old","destination_url":"http://new","request_domain":"example.com"}'
    )
    requestor = make_requestor(mock_http)
    result = Forem::RequestRedirect.create(
      { request_redirect: { original_url: "/old", destination_url: "http://new", request_domain: "example.com" } },
      requestor: requestor
    )
    assert_instance_of Forem::RequestRedirect, result
    assert_equal "/old", result.original_url
    assert_equal(
      { "request_redirect" => { "original_url" => "/old", "destination_url" => "http://new", "request_domain" => "example.com" } },
      JSON.parse(captured[:body])
    )
  end

  def test_retrieve
    mock_http, _ = stub_http_request(
      method: :get,
      path: "/api/admin/request_redirects/1",
      status: 200,
      body: '{"id":1,"original_url":"/old","destination_url":"http://new","request_domain":"example.com"}'
    )
    requestor = make_requestor(mock_http)
    result = Forem::RequestRedirect.retrieve(1, requestor: requestor)
    assert_instance_of Forem::RequestRedirect, result
    assert_equal 1, result.id
    assert_equal "example.com", result.request_domain
  end

  def test_update
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/admin/request_redirects/1",
      status: 200,
      body: '{"id":1,"original_url":"/new-old","destination_url":"http://new","request_domain":"example.com"}'
    )
    requestor = make_requestor(mock_http)
    result = Forem::RequestRedirect.update(1, { request_redirect: { original_url: "/new-old" } }, requestor: requestor)
    assert_instance_of Forem::RequestRedirect, result
    assert_equal "/new-old", result.original_url
    assert_equal({ "request_redirect" => { "original_url" => "/new-old" } }, JSON.parse(captured[:body]))
  end

  def test_delete_class_method
    mock_http, captured = stub_http_request(
      method: :delete,
      path: "/api/admin/request_redirects/1",
      status: 204,
      body: ""
    )
    requestor = make_requestor(mock_http)
    result = Forem::RequestRedirect.delete(1, requestor: requestor)
    assert_nil result
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/admin/request_redirects/1", captured[:path]
  end

  def test_instance_delete
    mock_http, captured = stub_http_request(
      method: :delete,
      path: "/api/admin/request_redirects/1",
      status: 204,
      body: ""
    )
    requestor = make_requestor(mock_http)
    redirect = Forem::RequestRedirect.construct_from({ "id" => 1 })
    redirect.delete(requestor: requestor)
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/admin/request_redirects/1", captured[:path]
  end
end
