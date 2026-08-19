require "test_helper"

class Forem::BadgeAchievementTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/badge_achievements", Forem::BadgeAchievement.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/badge_achievements", status: 200,
                                     body: '[{"id":9876,"user_id":123,"badge_id":45}]')
    requestor = make_requestor(mock_http)
    result = Forem::BadgeAchievement.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_instance_of Forem::BadgeAchievement, result.data[0]
    assert_equal 123, result.data[0].user_id
  end

  def test_list_passes_page_param
    mock_http, captured = stub_http_request(method: :get, path: "/api/badge_achievements", status: 200, body: "[]")
    requestor = make_requestor(mock_http)
    Forem::BadgeAchievement.list({ page: 2 }, requestor: requestor)
    assert_includes captured[:path], "page=2"
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/badge_achievements/9876", status: 200,
                                     body: '{"id":9876,"user_id":123,"badge_id":45}')
    requestor = make_requestor(mock_http)
    result = Forem::BadgeAchievement.retrieve(9876, requestor: requestor)
    assert_instance_of Forem::BadgeAchievement, result
    assert_equal 45, result.badge_id
  end

  def test_create
    mock_http, captured = stub_http_request(method: :post, path: "/api/badge_achievements", status: 201,
                                            body: '{"id":9876,"user_id":123,"badge_id":45}')
    requestor = make_requestor(mock_http)
    result = Forem::BadgeAchievement.create(
      { badge_achievement: { user_id: 123, badge_id: 45 } },
      requestor: requestor,
    )
    assert_instance_of Forem::BadgeAchievement, result
    assert_equal 9876, result.id
    assert_equal({ "badge_achievement" => { "user_id" => 123, "badge_id" => 45 } }, JSON.parse(captured[:body]))
  end

  def test_delete
    mock_http, captured = stub_http_request(method: :delete, path: "/api/badge_achievements/9876",
                                            status: 204, body: "")
    requestor = make_requestor(mock_http)
    result = Forem::BadgeAchievement.delete(9876, requestor: requestor)
    assert_nil result
    assert_equal "DELETE", captured[:method]
    assert_equal "/api/badge_achievements/9876", captured[:path]
  end

  def test_create_raises_on_validation_error
    mock_http, _ = stub_http_request(method: :post, path: "/api/badge_achievements", status: 422,
                                     body: '{"errors":["Badge has already been taken"]}')
    requestor = make_requestor(mock_http)
    error = assert_raises(Forem::InvalidRequestError) do
      Forem::BadgeAchievement.create(
        { badge_achievement: { user_id: 123, badge_id: 45 } },
        requestor: requestor,
      )
    end
    assert_match(/already been taken/, error.message)
  end
end
