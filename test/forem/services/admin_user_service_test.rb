require "test_helper"

class Forem::AdminUserServiceTest < Minitest::Test
  include StubRequestHelper

  def test_link_identity_posts_identity_and_returns_an_sdk_object
    mock_http, captured = stub_http_request(
      method: :post,
      path: "/api/admin/users/42/identities",
      status: 201,
      body: '{"id":7,"provider":"github","uid":"octocat"}'
    )
    client = client_with_http(mock_http)

    result = client.admin_users.link_identity(
      42,
      provider: "github",
      uid: "octocat",
      api_key: "override-key"
    )

    assert_instance_of Forem::ForemObject, result
    assert_equal 7, result.id
    assert_equal "POST", captured[:method]
    assert_equal "/api/admin/users/42/identities", captured[:path]
    assert_equal "override-key", captured[:headers]["api-key"]
    assert_equal({ "provider" => "github", "uid" => "octocat" }, JSON.parse(captured[:body]))
  end

  def test_bulk_link_identities_posts_identities_and_unwraps_result_objects
    body = <<~JSON
      {
        "results": [
          {"user_id":42,"status":"linked"},
          {"user_id":43,"status":"error","error_code":"uid_taken"}
        ]
      }
    JSON
    mock_http, captured = stub_http_request(
      method: :post,
      path: "/api/admin/users/identities/bulk",
      status: 200,
      body: body
    )
    client = client_with_http(mock_http)
    identities = [{ user_id: 42, uid: "octocat" }, { user_id: 43, uid: "hubot" }]

    result = client.admin_users.bulk_link_identities(provider: "github", identities: identities)

    assert_equal 2, result.length
    assert_instance_of Forem::ForemObject, result.first
    assert_equal "linked", result.first.status
    assert_equal "uid_taken", result.last.error_code
    assert_equal "POST", captured[:method]
    assert_equal "/api/admin/users/identities/bulk", captured[:path]
    assert_equal(
      {
        "provider" => "github",
        "identities" => [
          { "user_id" => 42, "uid" => "octocat" },
          { "user_id" => 43, "uid" => "hubot" }
        ]
      },
      JSON.parse(captured[:body])
    )
  end

  def test_identities_gets_and_unwraps_identity_objects
    mock_http, captured = stub_http_request(
      method: :get,
      path: "/api/admin/users/42/identities",
      status: 200,
      body: '{"identities":[{"id":7,"provider":"github","uid":"octocat"}]}'
    )
    client = client_with_http(mock_http)

    result = client.admin_users.identities(42)

    assert_equal 1, result.length
    assert_instance_of Forem::ForemObject, result.first
    assert_equal(
      { "id" => 7, "provider" => "github", "uid" => "octocat" },
      result.first.to_hash
    )
    assert_equal "GET", captured[:method]
    assert_equal "/api/admin/users/42/identities", captured[:path]
  end

  def test_unlink_identity_deletes_and_returns_an_sdk_object
    mock_http, captured = stub_http_request(
      method: :delete,
      path: "/api/admin/users/42/identities/7",
      status: 200,
      body: '{"id":7,"provider":"github","uid":"octocat"}'
    )
    client = client_with_http(mock_http)

    result = client.admin_users.unlink_identity(42, 7)

    assert_instance_of Forem::ForemObject, result
    assert_equal 7, result.id
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/admin/users/42/identities/7", captured[:path]
  end

  def test_unlink_identity_returns_nil_for_an_empty_response
    mock_http, = stub_http_request(
      method: :delete,
      path: "/api/admin/users/42/identities/7",
      status: 204,
      body: ""
    )
    client = client_with_http(mock_http)

    assert_nil client.admin_users.unlink_identity(42, 7)
  end

  def test_update_notification_settings_puts_wrapped_setting_and_returns_an_sdk_object
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/admin/users/42/notification_settings",
      status: 200,
      body: '{"email_newsletter":false}'
    )
    client = client_with_http(mock_http)

    result = client.admin_users.update_notification_settings(42, settings: { email_newsletter: false })

    assert_instance_of Forem::ForemObject, result
    assert_equal false, result.email_newsletter
    assert_equal "PUT", captured[:method]
    assert_equal "/api/admin/users/42/notification_settings", captured[:path]
    assert_equal(
      { "notification_setting" => { "email_newsletter" => false } },
      JSON.parse(captured[:body])
    )
  end

  def test_update_notification_settings_sends_every_supplied_key
    mock_http, captured = stub_http_request(
      method: :put,
      path: "/api/admin/users/42/notification_settings",
      status: 200,
      body: '{"email_newsletter":false,"email_digest_periodic":false}'
    )
    client = client_with_http(mock_http)

    client.admin_users.update_notification_settings(
      42, settings: { email_newsletter: false, email_digest_periodic: false }
    )

    assert_equal(
      { "notification_setting" => { "email_newsletter" => false,
                                    "email_digest_periodic" => false } },
      JSON.parse(captured[:body])
    )
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
