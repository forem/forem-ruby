require "test_helper"

class Forem::ArticleServiceTest < Minitest::Test
  include StubRequestHelper

  def test_list_gets_articles
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/articles", status: 200,
      body: '[{"id":1,"title":"Hello"}]'
    )
    client = client_with_http(mock_http)

    result = client.articles.list(tag: "ruby", per_page: 10)

    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Article, result.data[0]
    assert_equal "Hello", result.data[0].title
    assert_equal "GET", captured[:method]
    assert_equal "/api/articles", captured[:path].split("?").first
    assert_includes captured[:path], "tag=ruby"
  end

  def test_create_posts_article
    mock_http, captured = stub_http_request(
      method: :post, path: "/api/articles", status: 201,
      body: '{"id":1,"title":"New"}'
    )
    client = client_with_http(mock_http)

    result = client.articles.create(article: { title: "New", body_markdown: "body" })

    assert_instance_of Forem::Article, result
    assert_equal "New", result.title
    assert_equal "POST", captured[:method]
    assert_equal "/api/articles", captured[:path]
  end

  def test_retrieve_gets_a_single_article
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/articles/1", status: 200,
      body: '{"id":1,"title":"Found"}'
    )
    client = client_with_http(mock_http)

    result = client.articles.retrieve(1)

    assert_instance_of Forem::Article, result
    assert_equal "Found", result.title
    assert_equal "/api/articles/1", captured[:path].split("?").first
  end

  def test_search_gets_matching_articles
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/articles/search", status: 200,
      body: '[{"id":1,"title":"Ruby on Rails"}]'
    )
    client = client_with_http(mock_http)

    result = client.articles.search(q: "ruby on rails")

    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Article, result.data[0]
    assert_equal "Ruby on Rails", result.data[0].title
    assert_equal "GET", captured[:method]
    assert_equal "/api/articles/search", captured[:path].split("?").first
    assert_includes captured[:path], "q=ruby+on+rails"
  end

  def test_semantic_search_gets_semantically_matching_articles
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/articles/semantic_search", status: 200,
      body: '[{"id":1,"title":"Ruby on Rails Basics","distance":0.12,"similarity":0.88}]'
    )
    client = client_with_http(mock_http)

    result = client.articles.semantic_search(q: "how do I deploy a rails app", per_page: 5)

    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::Article, result.data[0]
    assert_equal "Ruby on Rails Basics", result.data[0].title
    assert_equal 0.88, result.data[0].similarity
    assert_equal "GET", captured[:method]
    assert_equal "/api/articles/semantic_search", captured[:path].split("?").first
    assert_includes captured[:path], "per_page=5"
  end

  def test_semantic_search_forwards_threshold_param
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/articles/semantic_search", status: 200,
      body: "[]"
    )
    client = client_with_http(mock_http)

    result = client.articles.semantic_search(q: "rails", threshold: 0.5)

    assert_equal [], result.data
    assert_includes captured[:path], "threshold=0.5"
  end

  def test_retrieve_by_path_gets_article_by_username_and_slug
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/articles/alice/hello-world", status: 200,
      body: '{"id":1,"title":"Hello World"}'
    )
    client = client_with_http(mock_http)

    result = client.articles.retrieve_by_path("alice", "hello-world")

    assert_instance_of Forem::Article, result
    assert_equal "Hello World", result.title
    assert_equal "/api/articles/alice/hello-world", captured[:path].split("?").first
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
