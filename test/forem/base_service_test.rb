require "test_helper"

class TestEnvelopeService < Forem::Services::BaseService
  def envelope(key, params)
    enveloped(key, params)
  end
end

class Forem::BaseServiceTest < Minitest::Test
  include StubRequestHelper

  def setup
    @service = TestEnvelopeService.new(nil)
  end

  def test_wraps_flat_params
    assert_equal({ badge: { title: "Top 7" } }, @service.envelope(:badge, { title: "Top 7" }))
  end

  def test_wraps_empty_params
    assert_equal({ badge: {} }, @service.envelope(:badge, {}))
  end

  def test_leaves_symbol_keyed_envelope_alone
    params = { badge: { title: "Top 7" } }
    assert_equal params, @service.envelope(:badge, params)
  end

  def test_leaves_string_keyed_envelope_alone
    params = { "badge" => { "title" => "Top 7" } }
    assert_equal params, @service.envelope(:badge, params)
  end
end
