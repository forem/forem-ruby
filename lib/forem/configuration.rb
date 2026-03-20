# lib/forem/configuration.rb
module Forem
  class Configuration
    attr_accessor :api_key, :api_base, :api_version, :open_timeout, :read_timeout,
                  :max_network_retries, :log_level, :logger

    def initialize
      @api_key = nil
      @api_base = "https://dev.to"
      @api_version = "v1"
      @open_timeout = 30
      @read_timeout = 80
      @max_network_retries = 1
      @log_level = nil
      @logger = nil
    end

    def initialize_dup(source)
      super
    end
  end
end
