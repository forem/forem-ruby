require "test_helper"

class Forem::ConnectionManagerTest < Minitest::Test
  def test_returns_net_http_connection
    manager = Forem::ConnectionManager.new
    conn = manager.connection_for(URI("https://dev.to"))
    assert_instance_of Net::HTTP, conn
    assert_equal "dev.to", conn.address
    assert_equal 443, conn.port
    assert conn.use_ssl?
  end

  def test_reuses_connection_for_same_host
    manager = Forem::ConnectionManager.new
    uri = URI("https://dev.to")
    conn1 = manager.connection_for(uri)
    conn2 = manager.connection_for(uri)
    assert_same conn1, conn2
  end

  def test_different_connection_for_different_host
    manager = Forem::ConnectionManager.new
    conn1 = manager.connection_for(URI("https://dev.to"))
    conn2 = manager.connection_for(URI("https://other.forem.com"))
    refute_same conn1, conn2
  end
end
