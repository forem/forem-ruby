require "test_helper"

class Forem::AdminUserTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/admin/users", Forem::AdminUser.resource_path
  end

  def test_create
    mock_http, captured = stub_http_request(method: :post, path: "/api/admin/users", status: 201, body: '{"id":1,"username":"newuser","email":"newuser@example.com"}')
    requestor = make_requestor(mock_http)
    result = Forem::AdminUser.create({ user: { email: "newuser@example.com", username: "newuser" } }, requestor: requestor)
    assert_instance_of Forem::AdminUser, result
    assert_equal "newuser", result.username
    assert_equal "POST", captured[:method]
    assert_equal "/api/admin/users", captured[:path]
  end

  def test_list_unwraps_users_envelope
    body = '{"users":[{"id":1,"username":"alice"},{"id":2,"username":"bob"}],"page":1,"per_page":25,"total":2}'
    mock_http, captured = stub_http_request(method: :get, path: "/api/admin/users", status: 200, body: body)
    requestor = make_requestor(mock_http)
    result = Forem::AdminUser.list({ email: "alice@example.com" }, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 2, result.length
    assert_instance_of Forem::AdminUser, result[0]
    assert_equal "alice", result[0].username
    assert_includes captured[:path], "email=alice%40example.com"
  end

  def test_retrieve_and_update
    mock_http, _ = stub_http_request(method: :get, path: "/api/admin/users/42", status: 200, body: '{"id":42,"username":"alice"}')
    requestor = make_requestor(mock_http)
    user = Forem::AdminUser.retrieve(42, requestor: requestor)
    assert_instance_of Forem::AdminUser, user
    assert_equal "alice", user.username

    mock_http2, captured2 = stub_http_request(method: :put, path: "/api/admin/users/42", status: 200, body: '{"id":42,"name":"Alice Updated"}')
    requestor2 = make_requestor(mock_http2)
    updated = Forem::AdminUser.update(42, { name: "Alice Updated" }, requestor: requestor2)
    assert_equal "Alice Updated", updated.name
    assert_equal "PUT", captured2[:method]
    assert_equal({ "name" => "Alice Updated" }, JSON.parse(captured2[:body]))
  end

  def test_update_email_status_and_merge
    mock_http, captured = stub_http_request(method: :put, path: "/api/admin/users/42/email", status: 200, body: '{"id":42,"email":"new@example.com"}')
    res = Forem::AdminUser.update_email(42, email: "new@example.com", requestor: make_requestor(mock_http))
    assert_equal "new@example.com", res.email
    assert_equal({ "email" => "new@example.com" }, JSON.parse(captured[:body]))

    mock_http2, captured2 = stub_http_request(method: :put, path: "/api/admin/users/42/status", status: 200, body: '{"id":42,"status":"Suspended"}')
    res2 = Forem::AdminUser.update_status(42, status: "Suspended", note: "Spam", requestor: make_requestor(mock_http2))
    assert_equal "Suspended", res2.status
    assert_equal({ "status" => "Suspended", "note" => "Spam" }, JSON.parse(captured2[:body]))

    mock_http3, captured3 = stub_http_request(method: :post, path: "/api/admin/users/42/merge", status: 200, body: '{"id":42,"username":"alice"}')
    res3 = Forem::AdminUser.merge(42, merge_user_id: 99, requestor: make_requestor(mock_http3))
    assert_instance_of Forem::AdminUser, res3
    assert_equal 42, res3.id
    assert_equal({ "merge_user_id" => 99 }, JSON.parse(captured3[:body]))
  end

  def test_notes_and_create_note
    mock_http, captured = stub_http_request(method: :get, path: "/api/admin/users/42/notes", status: 200, body: '{"notes":[{"id":1,"content":"Reviewed"}]}')
    notes = Forem::AdminUser.notes(42, requestor: make_requestor(mock_http))
    assert_equal 1, notes.length
    assert_equal "Reviewed", notes[0].content
    assert_equal "/api/admin/users/42/notes", captured[:path]

    mock_http2, captured2 = stub_http_request(method: :post, path: "/api/admin/users/42/notes", status: 201, body: '{"id":2,"content":"Warned","reason":"spam"}')
    note = Forem::AdminUser.create_note(42, content: "Warned", reason: "spam", requestor: make_requestor(mock_http2))
    assert_equal "Warned", note.content
    assert_equal({ "content" => "Warned", "reason" => "spam" }, JSON.parse(captured2[:body]))
  end
end
