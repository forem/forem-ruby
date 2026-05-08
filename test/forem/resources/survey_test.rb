require "test_helper"

class Forem::SurveyTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/surveys", Forem::Survey.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/surveys", status: 200, body: '[{"id":1,"title":"Survey One"}]')
    requestor = make_requestor(mock_http)
    result = Forem::Survey.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::Survey, result.data[0]
    assert_equal "Survey One", result.data[0].title
  end

  def test_retrieve
    mock_http, _ = stub_http_request(method: :get, path: "/api/surveys/1", status: 200, body: '{"id":1,"title":"Found"}')
    requestor = make_requestor(mock_http)
    result = Forem::Survey.retrieve(1, requestor: requestor)
    assert_instance_of Forem::Survey, result
    assert_equal "Found", result.title
  end

  def test_poll_votes
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/surveys/1/poll_votes", status: 200,
      body: '[{"id":10,"poll_option_id":3},{"id":11,"poll_option_id":4}]'
    )
    requestor = make_requestor(mock_http)
    survey = Forem::Survey.construct_from({"id" => 1})
    result = survey.poll_votes({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 2, result.length
    assert_instance_of Forem::ForemObject, result[0]
    assert_equal 10, result[0].id
    assert_equal "GET", captured[:method]
    assert_equal "/api/surveys/1/poll_votes", captured[:path].split("?").first
  end

  def test_poll_text_responses
    mock_http, captured = stub_http_request(
      method: :get, path: "/api/surveys/1/poll_text_responses", status: 200,
      body: '[{"id":21,"text_content":"hello"}]'
    )
    requestor = make_requestor(mock_http)
    survey = Forem::Survey.construct_from({"id" => 1})
    result = survey.poll_text_responses({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.length
    assert_equal "hello", result[0].text_content
    assert_equal "/api/surveys/1/poll_text_responses", captured[:path].split("?").first
  end

  def test_poll_votes_uses_after_cursor_for_paging
    # First page: 2 records (per_page=2). Cursor should advance to id=11.
    page1_http, page1_captured = stub_http_request(
      method: :get, path: "/api/surveys/1/poll_votes", status: 200,
      body: '[{"id":10},{"id":11}]'
    )
    requestor = make_requestor(page1_http)
    survey = Forem::Survey.construct_from({"id" => 1})
    page1 = survey.poll_votes({per_page: 2}, requestor: requestor)
    assert page1.has_more?
    refute_includes page1_captured[:path], "after="

    # Second page request swaps in the new mock and should carry after=11.
    page2_http, page2_captured = stub_http_request(
      method: :get, path: "/api/surveys/1/poll_votes", status: 200,
      body: '[{"id":12}]'
    )
    requestor.instance_variable_set(:@connection_manager, mock_conn(page2_http))
    page2 = page1.next_page
    assert_instance_of Forem::ListObject, page2
    assert_equal 1, page2.length
    assert_includes page2_captured[:path], "after=11"
    refute page2.has_more?
  end

  private

  def mock_conn(mock_http)
    cm = Minitest::Mock.new
    cm.expect(:connection_for, mock_http, [URI], open_timeout: Integer, read_timeout: Integer)
    cm
  end
end
