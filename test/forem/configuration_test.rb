# test/forem/configuration_test.rb
require "test_helper"

class Forem::ConfigurationTest < Minitest::Test
  def test_default_api_base
    assert_equal "https://dev.to", Forem::Configuration.new.api_base
  end

  def test_default_api_version
    assert_equal "v1", Forem::Configuration.new.api_version
  end

  def test_default_open_timeout
    assert_equal 30, Forem::Configuration.new.open_timeout
  end

  def test_default_read_timeout
    assert_equal 80, Forem::Configuration.new.read_timeout
  end

  def test_default_max_network_retries
    assert_equal 1, Forem::Configuration.new.max_network_retries
  end

  def test_api_key_default_is_nil
    assert_nil Forem::Configuration.new.api_key
  end

  def test_attributes_are_writable
    config = Forem::Configuration.new
    config.api_key = "test-key-123"
    config.api_base = "https://custom.forem.com"
    config.api_version = "v2"
    config.open_timeout = 60
    config.read_timeout = 120
    config.max_network_retries = 5

    assert_equal "test-key-123", config.api_key
    assert_equal "https://custom.forem.com", config.api_base
    assert_equal "v2", config.api_version
    assert_equal 60, config.open_timeout
    assert_equal 120, config.read_timeout
    assert_equal 5, config.max_network_retries
  end

  def test_no_global_module_state
    refute_respond_to Forem, :configuration,
                      "Forem.configuration was removed in 0.1 — Configuration is per-Client now"
    refute_respond_to Forem, :api_key,
                      "Forem.api_key was removed in 0.1 — pass the key to Forem::Client.new"
    refute_respond_to Forem, :configure,
                      "Forem.configure was removed in 0.1 — configure each Forem::Client directly"
    refute_respond_to Forem, :default_requestor,
                      "Forem.default_requestor was removed in 0.1 — every call goes through a Forem::Client"
  end
end
