require "test_helper"

class Forem::PodcastEpisodeTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/podcast_episodes", Forem::PodcastEpisode.resource_path
  end

  def test_list
    mock_http, _ = stub_http_request(method: :get, path: "/api/podcast_episodes", status: 200, body: '[{"id":1,"title":"Episode One"}]')
    requestor = make_requestor(mock_http)
    result = Forem::PodcastEpisode.list({}, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.data.length
    assert_instance_of Forem::PodcastEpisode, result.data[0]
    assert_equal "Episode One", result.data[0].title
  end
end
