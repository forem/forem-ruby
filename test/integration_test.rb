require "test_helper"

class IntegrationTest < Minitest::Test
  include StubRequestHelper

  def test_full_client_workflow
    # List articles
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles", status: 200, body: '[{"id":1,"title":"First"},{"id":2,"title":"Second"}]')
    client = Forem::Client.new("test-key")
    client.requestor.instance_variable_set(:@connection_manager, mock_conn(mock_http))

    articles = client.articles.list(per_page: 30)
    assert_instance_of Forem::ListObject, articles
    assert_equal 2, articles.data.length
    assert_equal "First", articles.data[0].title
    assert_instance_of Forem::Article, articles.data[0]
  end

  def test_retrieve_single_resource
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/42", status: 200, body: '{"id":42,"title":"Deep Dive","body_markdown":"# Hello","user":{"id":1,"username":"alice"}}')
    client = Forem::Client.new("test-key")
    client.requestor.instance_variable_set(:@connection_manager, mock_conn(mock_http))

    article = client.articles.retrieve(42)
    assert_instance_of Forem::Article, article
    assert_equal 42, article.id
    assert_equal "Deep Dive", article.title
    # Nested object
    assert_equal "alice", article.user.username
  end

  def test_create_resource
    mock_http, captured = stub_http_request(method: :post, path: "/api/articles", status: 201, body: '{"id":99,"title":"New Post"}')
    client = Forem::Client.new("test-key")
    client.requestor.instance_variable_set(:@connection_manager, mock_conn(mock_http))

    article = client.articles.create(article: { title: "New Post", body_markdown: "Content" })
    assert_instance_of Forem::Article, article
    assert_equal 99, article.id
    assert_equal "New Post", article.title
    # Verify JSON body was sent
    assert_includes captured[:body], "New Post"
  end

  def test_error_handling
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/999", status: 404, body: '{"error":"not found","status":404}')
    client = Forem::Client.new("test-key")
    client.requestor.instance_variable_set(:@connection_manager, mock_conn(mock_http))

    err = assert_raises(Forem::NotFoundError) { client.articles.retrieve(999) }
    assert_equal 404, err.http_status
    assert_equal "not found", err.message
  end

  def test_explicit_requestor_workflow
    # Class-level resource calls require an explicit :requestor opt — there
    # is no global default. In normal use this is injected by Forem::Client
    # via its services; the same path is exercised here directly.
    mock_http, captured = stub_http_request(method: :get, path: "/api/tags", status: 200, body: '[{"id":1,"name":"ruby"}]')

    config = Forem::Configuration.new
    config.api_key = "explicit-test-key"
    config.max_network_retries = 0
    requestor = Forem::APIRequestor.new(config: config)
    requestor.instance_variable_set(:@connection_manager, mock_conn(mock_http))

    tags = Forem::Tag.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, tags
    assert_equal "ruby", tags.data[0].name
    assert_equal "explicit-test-key", captured[:headers]["api-key"]
  end

  def test_class_level_call_without_requestor_raises
    # No global default exists — calling a class-level resource method
    # without a :requestor must fail loudly rather than silently
    # falling through to an unauthenticated request.
    err = assert_raises(ArgumentError) { Forem::Tag.list }
    assert_match(/explicit requestor/, err.message)
    assert_match(/Forem::Client/, err.message)
  end

  def test_to_hash_round_trip
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles/1", status: 200, body: '{"id":1,"title":"Test","tags":["ruby","api"],"user":{"id":5,"name":"Bob"}}')
    client = Forem::Client.new("test-key")
    client.requestor.instance_variable_set(:@connection_manager, mock_conn(mock_http))

    article = client.articles.retrieve(1)
    hash = article.to_hash
    assert_equal 1, hash["id"]
    assert_equal "Test", hash["title"]
    assert_equal ["ruby", "api"], hash["tags"]
    assert_equal({"id" => 5, "name" => "Bob"}, hash["user"])
  end

  private

  def mock_conn(mock_http)
    conn_manager = Minitest::Mock.new
    conn_manager.expect(:connection_for, mock_http, [URI], open_timeout: Integer, read_timeout: Integer)
    conn_manager
  end
end
