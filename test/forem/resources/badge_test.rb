require "test_helper"

class Forem::BadgeTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/badges", Forem::Badge.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/badges", status: 200,
                                     body: '[{"id":45,"title":"Top 7","slug":"top-7"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Badge.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::Badge, result.data[0]
    assert_equal "Top 7", result.data[0].title
    assert_equal "top-7", result.data[0].slug
  end

  def test_list_passes_page_param
    mock_http, captured = stub_http_request(method: :get, path: "/api/badges", status: 200, body: "[]")
    requestor = make_requestor(mock_http)
    Forem::Badge.list({ page: 2 }, requestor: requestor)
    assert_includes captured[:path], "page=2"
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/badges/45", status: 200,
                                     body: '{"id":45,"title":"Top 7","allow_multiple_awards":false}')
    requestor = make_requestor(mock_http)
    result = Forem::Badge.retrieve(45, requestor: requestor)
    assert_instance_of Forem::Badge, result
    assert_equal "Top 7", result.title
    assert_equal false, result.allow_multiple_awards
  end

  def test_create
    mock_http, _ = stub_http_request(method: :post, path: "/api/badges", status: 201,
                                     body: '{"id":46,"title":"Forem Contributor"}')
    requestor = make_requestor(mock_http)
    result = Forem::Badge.create({ badge: { title: "Forem Contributor" } }, requestor: requestor)
    assert_instance_of Forem::Badge, result
    assert_equal "Forem Contributor", result.title
  end

  def test_update
    mock_http, _ = stub_http_request(method: :put, path: "/api/badges/45", status: 200,
                                     body: '{"id":45,"title":"Renamed"}')
    requestor = make_requestor(mock_http)
    result = Forem::Badge.update(45, { badge: { title: "Renamed" } }, requestor: requestor)
    assert_instance_of Forem::Badge, result
    assert_equal "Renamed", result.title
  end

  def test_delete
    mock_http, captured = stub_http_request(method: :delete, path: "/api/badges/45", status: 204, body: "")
    requestor = make_requestor(mock_http)
    badge = Forem::Badge.construct_from({ "id" => 45 })
    badge.delete(requestor: requestor)
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/badges/45", captured[:path]
  end

  def test_create_raises_on_validation_error
    mock_http, _ = stub_http_request(method: :post, path: "/api/badges", status: 422,
                                     body: '{"errors":["Title has already been taken"]}')
    requestor = make_requestor(mock_http)
    assert_raises(Forem::InvalidRequestError) do
      Forem::Badge.create({ badge: { title: "Top 7" } }, requestor: requestor)
    end
  end
end
