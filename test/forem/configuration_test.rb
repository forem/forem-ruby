# test/forem/configuration_test.rb
require "test_helper"

class Forem::ConfigurationTest < Minitest::Test
  def setup
    @original_config = Forem.configuration.dup
  end

  def teardown
    Forem.configuration = @original_config
  end

  def test_default_api_base
    assert_equal "https://dev.to", Forem.configuration.api_base
  end

  def test_default_api_version
    assert_equal "v1", Forem.configuration.api_version
  end

  def test_default_open_timeout
    assert_equal 30, Forem.configuration.open_timeout
  end

  def test_default_read_timeout
    assert_equal 80, Forem.configuration.read_timeout
  end

  def test_default_max_network_retries
    assert_equal 1, Forem.configuration.max_network_retries
  end

  def test_api_key_accessor
    Forem.api_key = "test-key-123"
    assert_equal "test-key-123", Forem.api_key
    assert_equal "test-key-123", Forem.configuration.api_key
  end

  def test_configure_block
    Forem.configure do |c|
      c.api_key = "block-key"
      c.api_base = "https://custom.forem.com"
    end
    assert_equal "block-key", Forem.api_key
    assert_equal "https://custom.forem.com", Forem.configuration.api_base
  end

  def test_api_key_default_is_nil
    config = Forem::Configuration.new
    assert_nil config.api_key
  end
end
