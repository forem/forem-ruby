require "net/http"
require "uri"

module Forem
  class ConnectionManager
    def initialize
      @connections = {}
    end

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
