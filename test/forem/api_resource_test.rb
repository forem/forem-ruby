require "test_helper"

class TestResource < Forem::APIResource
  extend Forem::APIOperations::Retrieve
  OBJECT_NAME = "test_resource"
  RESOURCE_PATH = "/api/test_resources"
end

class TestResourceNoRetrieve < Forem::APIResource
  OBJECT_NAME = "no_retrieve"
  RESOURCE_PATH = "/api/no_retrieves"
end

class Forem::APIResourceTest < Minitest::Test
  def test_resource_path_class_method
    assert_equal "/api/test_resources", TestResource.resource_path
  end

  def test_resource_url_instance_with_id
    obj = TestResource.construct_from({"id" => 42})
    assert_equal "/api/test_resources/42", obj.resource_url
  end

  def test_resource_url_raises_without_id
    obj = TestResource.construct_from({})
    assert_raises(Forem::InvalidRequestError) { obj.resource_url }
  end

  def test_retrieve_available_when_mixin_extended
    assert_respond_to TestResource, :retrieve
  end

  def test_retrieve_not_available_without_mixin
    refute_respond_to TestResourceNoRetrieve, :retrieve
  end

  def test_construct_from_attaches_requestor
    fake = Object.new
    obj = TestResource.construct_from({"id" => 1}, requestor: fake)
    assert_same fake, obj.requestor
  end

  def test_instance_request_uses_attached_requestor
    # Regression for Paolo's #3: an object returned by a Client-issued call
    # must reuse the client's requestor for follow-up calls without the
    # caller having to pass :requestor explicitly.
    captured_requestor = nil
    fake = Object.new
    fake.define_singleton_method(:request) do |*args, **kwargs|
      captured_requestor = self
      Forem::ForemResponse.new(http_status: 200, http_body: "{}", http_headers: {})
    end
    obj = TestResource.construct_from({"id" => 7}, requestor: fake)
    obj.request(:get, "/api/test_resources/7")
    assert_same fake, captured_requestor
  end
end
