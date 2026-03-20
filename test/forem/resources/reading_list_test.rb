require "test_helper"

class Forem::ReadingListTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/readinglist", Forem::ReadingList.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/readinglist", status: 200, body: '[{"id":1,"title":"Article One"}]')
    requestor = make_requestor(mock_http)
    result = Forem::ReadingList.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::ReadingList, result.data[0]
    assert_equal "Article One", result.data[0].title
  end
end
