require "test_helper"

class Forem::RecommendedArticlesListTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/recommended_articles_lists", Forem::RecommendedArticlesList.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/recommended_articles_lists", status: 200, body: '[{"id":1,"name":"Top Picks"}]')
    requestor = make_requestor(mock_http)
    result = Forem::RecommendedArticlesList.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::RecommendedArticlesList, result.data[0]
    assert_equal "Top Picks", result.data[0].name
  end

  def test_create
    mock_http, _ = stub_http_request(method: :post, path: "/api/recommended_articles_lists", status: 201, body: '{"id":1,"name":"New List"}')
    requestor = make_requestor(mock_http)
    result = Forem::RecommendedArticlesList.create({ name: "New List" }, requestor: requestor)
    assert_instance_of Forem::RecommendedArticlesList, result
    assert_equal "New List", result.name
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/recommended_articles_lists/1", status: 200, body: '{"id":1,"name":"Found"}')
    requestor = make_requestor(mock_http)
    result = Forem::RecommendedArticlesList.retrieve(1, requestor: requestor)
    assert_instance_of Forem::RecommendedArticlesList, result
    assert_equal "Found", result.name
  end

  def test_update
    mock_http, _ = stub_http_request(method: :put, path: "/api/recommended_articles_lists/1", status: 200, body: '{"id":1,"name":"Updated"}')
    requestor = make_requestor(mock_http)
    result = Forem::RecommendedArticlesList.update(1, { name: "Updated" }, requestor: requestor)
    assert_instance_of Forem::RecommendedArticlesList, result
    assert_equal "Updated", result.name
  end
end
