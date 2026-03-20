require "test_helper"

class Forem::ClientTest < Minitest::Test
  include StubRequestHelper

  def test_client_initializes_with_api_key
    client = Forem::Client.new("my-api-key")
    assert_equal "my-api-key", client.config.api_key
  end

  def test_client_accepts_custom_api_base
    client = Forem::Client.new("key", api_base: "https://custom.forem.com")
    assert_equal "https://custom.forem.com", client.config.api_base
  end

  def test_client_has_all_resource_accessors
    client = Forem::Client.new("key")
    %i[articles users comments organizations tags follows followers
       reading_list podcast_episodes videos profile_images billboards
       pages segments reactions recommended_articles_lists agent_sessions
       surveys analytics health_checks admin_users].each do |resource|
      assert_respond_to client, resource, "Client missing #{resource} accessor"
    end
  end

  def test_articles_service_delegates_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/articles", status: 200, body: '[{"id":1}]')
    client = Forem::Client.new("test-key")
    conn_manager = Minitest::Mock.new
    conn_manager.expect(:connection_for, mock_http, [URI], open_timeout: Integer, read_timeout: Integer)
    client.requestor.instance_variable_set(:@connection_manager, conn_manager)

    result = client.articles.list
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data[0].id
  end

  def test_users_service_delegates_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/users/1", status: 200, body: '{"id":1,"username":"alice"}')
    client = Forem::Client.new("test-key")
    conn_manager = Minitest::Mock.new
    conn_manager.expect(:connection_for, mock_http, [URI], open_timeout: Integer, read_timeout: Integer)
    client.requestor.instance_variable_set(:@connection_manager, conn_manager)

    result = client.users.retrieve(1)
    assert_instance_of Forem::User, result
    assert_equal "alice", result.username
  end

  def test_client_uses_separate_config_from_global
    Forem.api_key = "global-key"
    client = Forem::Client.new("client-key")
    assert_equal "client-key", client.config.api_key
    assert_equal "global-key", Forem.api_key
  end
end
