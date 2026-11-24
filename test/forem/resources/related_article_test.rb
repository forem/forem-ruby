require "test_helper"

class Forem::RelatedArticleTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/related_articles", Forem::RelatedArticle.resource_path
  end

  def test_list
    body = '[{"id":10,"title":"Related Ruby","discovery_match":["semantic"],"discovery_rank":0.91}]'
    mock_http, captured = stub_http_request(method: :get, path: "/api/related_articles", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::RelatedArticle.list({ organization_id: 7, q: "ruby" }, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.length
    assert_instance_of Forem::RelatedArticle, result[0]
    assert_equal "Related Ruby", result[0].title
    assert_equal ["semantic"], result[0].discovery_match
    assert_equal 0.91, result[0].discovery_rank
    assert_equal "GET", captured[:method]
    assert_includes captured[:path], "organization_id=7"
    assert_includes captured[:path], "q=ruby"
  end
end
