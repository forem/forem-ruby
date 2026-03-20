require "net/http"
require "uri"

module Forem
  # Manages a pool of persistent Net::HTTP connections keyed by host and port.
  #
  # {ConnectionManager} is used internally by {APIRequestor} to reuse
  # keep-alive TCP connections across multiple requests to the same server,
  # reducing connection-setup overhead.
  #
  # Each {APIRequestor} instance owns exactly one ConnectionManager. Connections
  # are lazily created on first use and kept open with a 30-second keep-alive
  # timeout.
  #
  # @example Creating a connection manager (internal use)
  #   manager = Forem::ConnectionManager.new
  #   uri     = URI("https://dev.to/api/articles")
  #   conn    = manager.connection_for(uri)
  class ConnectionManager
    # Create a new, empty ConnectionManager with no active connections.
    #
    # @return [ConnectionManager]
    def initialize
      @connections = {}
    end

    # Return a Net::HTTP connection for the given URI, creating one if needed.
    #
    # Connections are keyed by <tt>"host:port"</tt> so the same object is
    # reused for every request to the same server. SSL is enabled automatically
    # when the URI scheme is <tt>"https"</tt>.
    #
    # @param uri [URI] the parsed URI whose host and port identify the server.
    # @param open_timeout [Integer] seconds to wait while opening the TCP
    #   connection. Defaults to +30+.
    # @param read_timeout [Integer] seconds to wait for a response after the
    #   connection is established. Defaults to +80+.
    # @return [Net::HTTP] a (possibly already-started) HTTP connection object.
    #
    # @example
    #   uri  = URI("https://dev.to/api/articles")
    #   conn = manager.connection_for(uri, open_timeout: 10, read_timeout: 30)
    def connection_for(uri, open_timeout: 30, read_timeout: 80)
      key = "#{uri.host}:#{uri.port}"
      return @connections[key] if @connections[key]

      conn = Net::HTTP.new(uri.host, uri.port)
      conn.use_ssl = uri.scheme == "https"
      conn.open_timeout = open_timeout
      conn.read_timeout = read_timeout
      conn.keep_alive_timeout = 30
      @connections[key] = conn
    end

    # Close all open connections and remove them from the pool.
    #
    # Gracefully handles connections that are already closed by swallowing
    # any {IOError} raised during shutdown. After this call the manager is
    # empty and new connections will be created on the next {#connection_for}
    # call.
    #
    # @return [void]
    #
    # @example
    #   manager.clear
    def clear
      @connections.each_value do |conn|
        conn.finish if conn.started?
      rescue IOError
        # already closed
      end
      @connections.clear
    end
  end
end
