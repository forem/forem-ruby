require "test_helper"

class Forem::BillboardCampaignTest < Minitest::Test
  include StubRequestHelper

  def test_resource_path
    assert_equal "/api/billboard_campaigns", Forem::BillboardCampaign.resource_path
  end

  def test_list
    body = '[{"id":1,"name":"Q4 Launch","max_impressions_count":100000}]'
    mock_http, captured = stub_http_request(method: :get, path: "/api/billboard_campaigns", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::BillboardCampaign.list({ page: 1 }, requestor: requestor)
    assert_instance_of Forem::ListObject, result
    assert_equal 1, result.length
    assert_instance_of Forem::BillboardCampaign, result[0]
    assert_equal "Q4 Launch", result[0].name
    assert_equal "GET", captured[:method]
  end

  def test_retrieve
    body = '{"id":5,"name":"Spring Campaign","ideal_daily_impressions":2500}'
    mock_http, captured = stub_http_request(method: :get, path: "/api/billboard_campaigns/5", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::BillboardCampaign.retrieve(5, requestor: requestor)
    assert_instance_of Forem::BillboardCampaign, result
    assert_equal 5, result.id
    assert_equal 2500, result.ideal_daily_impressions
    assert_equal "/api/billboard_campaigns/5", captured[:path]
  end

  def test_create
    body = '{"id":9,"name":"New Campaign","max_clicks_count":500}'
    mock_http, captured = stub_http_request(method: :post, path: "/api/billboard_campaigns", status: 201, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::BillboardCampaign.create({ name: "New Campaign", max_clicks_count: 500 }, requestor: requestor)
    assert_instance_of Forem::BillboardCampaign, result
    assert_equal 9, result.id
    assert_equal "POST", captured[:method]
    assert_equal({ "name" => "New Campaign", "max_clicks_count" => 500 }, JSON.parse(captured[:body]))
  end

  def test_update
    body = '{"id":9,"name":"Renamed Campaign"}'
    mock_http, captured = stub_http_request(method: :put, path: "/api/billboard_campaigns/9", status: 200, body: body)
    requestor = make_requestor(mock_http)

    result = Forem::BillboardCampaign.update(9, { name: "Renamed Campaign" }, requestor: requestor)
    assert_instance_of Forem::BillboardCampaign, result
    assert_equal "Renamed Campaign", result.name
    assert_equal "PUT", captured[:method]
    assert_equal "/api/billboard_campaigns/9", captured[:path]
  end
end
