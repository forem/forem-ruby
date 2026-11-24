require "test_helper"

class Forem::ArticleTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/articles", Forem::Article.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles", status: 200, body: '[{"id":1,"title":"Hello"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Article.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Article, result.data[0]
    assert_equal "Hello", result.data[0].title
  end

  def test_create
    mock_http, _ = stub_http_request(method: :post, path: "/api/articles", status: 201, body: '{"id":1,"title":"New"}')
    requestor = make_requestor(mock_http)
    result = Forem::Article.create({ article: { title: "New", body_markdown: "body" } }, requestor: requestor)
    assert_instance_of Forem::Article, result
    assert_equal "New", result.title
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/1", status: 200, body: '{"id":1,"title":"Found"}')
    requestor = make_requestor(mock_http)
    result = Forem::Article.retrieve(1, requestor: requestor)
    assert_instance_of Forem::Article, result
    assert_equal "Found", result.title
  end

  def test_update
    mock_http, _ = stub_http_request(method: :put, path: "/api/articles/1", status: 200, body: '{"id":1,"title":"Updated"}')
    requestor = make_requestor(mock_http)
    result = Forem::Article.update(1, { article: { title: "Updated" } }, requestor: requestor)
    assert_instance_of Forem::Article, result
  end

  def test_me
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/me", status: 200, body: '[{"id":1,"title":"Mine"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Article.me({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Article, result[0]
    assert_equal "Mine", result[0].title
  end

  def test_me_published
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/me/published", status: 200, body: '[{"id":1,"title":"Published"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Article.me_published({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Article, result[0]
    assert_equal "Published", result[0].title
  end

  def test_me_unpublished
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/me/unpublished", status: 200, body: '[{"id":2,"title":"Draft"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Article.me_unpublished({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Article, result[0]
    assert_equal "Draft", result[0].title
  end

  def test_me_all
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/me/all", status: 200, body: '[{"id":1},{"id":2}]')
    requestor = make_requestor(mock_http)
    result = Forem::Article.me_all({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 2, result.length
    assert_instance_of Forem::Article, result[0]
  end

  def test_latest
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/latest", status: 200, body: '[{"id":1}]')
    requestor = make_requestor(mock_http)
    result = Forem::Article.latest({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Article, result[0]
  end

  def test_search
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/search", status: 200, body: '[{"id":1}]')
    requestor = make_requestor(mock_http)
    result = Forem::Article.search({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
  end

  def test_semantic_search
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/articles/semantic_search",
      status: 200,
      body: '[{"id":1,"title":"Ruby on Rails Basics","distance":0.12,"similarity":0.88}]'
    )
    requestor = make_requestor(mock_http)
    result = Forem::Article.semantic_search({ q: "ruby on rails" }, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Article, result[0]
    assert_equal "Ruby on Rails Basics", result[0].title
    assert_equal 0.88, result[0].similarity
    assert_equal "GET", captured[:method]
    assert_equal "/api/articles/semantic_search?q=ruby+on+rails", captured[:path]
  end

  def test_retrieve_by_path
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/alice/hello-world", status: 200, body: '{"id":1,"title":"Hello World"}')
    requestor = make_requestor(mock_http)
    result = Forem::Article.retrieve_by_path("alice", "hello-world", requestor: requestor)
    assert_instance_of Forem::Article, result
    assert_equal "Hello World", result.title
  end

  def test_unpublish
    mock_http, _ = stub_http_request(method: :put, path: "/api/articles/1/unpublish", status: 204, body: "")
    requestor = make_requestor(mock_http)
    article = Forem::Article.construct_from({"id" => 1})
    result = article.unpublish(requestor: requestor)
    assert_equal 204, result.http_status
  end

  def test_class_unpublish
    mock_http, captured = stub_http_request(method: :put, path: "/api/articles/42/unpublish", status: 204, body: "")
    requestor = make_requestor(mock_http)
    result = Forem::Article.unpublish(42, requestor: requestor)
    assert_equal 204, result.http_status
    assert_equal "PUT", captured[:method]
    assert_equal "/api/articles/42/unpublish", captured[:path]
  end

  def test_preview
    body = '{"processed_html":"<h1>Hello</h1>","body_html":"<h1>Hello</h1>","title":"Hello","reading_time_minutes":1}'
    mock_http, captured = stub_http_request(method: :post, path: "/api/articles/preview", status: 200, body: body)
    requestor = make_requestor(mock_http)
    result = Forem::Article.preview({ body_markdown: "# Hello", title: "Hello" }, requestor: requestor)
    assert_instance_of Forem::ForemObject, result
    assert_equal "<h1>Hello</h1>", result.processed_html
    assert_equal 1, result.reading_time_minutes
    assert_equal "POST", captured[:method]
    assert_equal "/api/articles/preview", captured[:path]
  end
end
