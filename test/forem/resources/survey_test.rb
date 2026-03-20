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

  def test_responses
    mock_http, captured = stub_http_request(method: :get, path: "/api/surveys/1/responses", status: 200, body: '[{"id":10,"answer":"Yes"},{"id":11,"answer":"No"}]')
    requestor = make_requestor(mock_http)
    survey = Forem::Survey.construct_from({"id" => 1})
    result = survey.responses({}, requestor: requestor)
    assert_instance_of Array, result
    assert_equal 2, result.length
    assert_instance_of Forem::ForemObject, result[0]
    assert_equal "Yes", result[0].answer
    assert_equal "GET", captured[:method]
    assert_equal "/api/surveys/1/responses", captured[:path].split("?").first
  end
end
