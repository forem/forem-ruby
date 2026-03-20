# lib/forem/configuration.rb
module Forem
  # Holds all configuration settings for the Forem API client.
  #
  # Instances are typically created and mutated through {Forem.configure}.
  #
  # @example Setting up configuration
  #   Forem.configure do |config|
  #     config.api_key  = "my_api_key"
  #     config.api_base = "https://dev.to"
  #   end
  class Configuration
    # @!attribute [rw] api_key
    #   @return [String, nil] the API key used to authenticate requests.
    #     Corresponds to the `api-key` HTTP header sent with every request.
    #     Defaults to +nil+.

    # @!attribute [rw] api_base
    #   @return [String] the base URL of the Forem instance.
    #     Defaults to <tt>"https://dev.to"</tt>.

    # @!attribute [rw] api_version
    #   @return [String] the API version string included in Accept headers.
    #     Defaults to <tt>"v1"</tt>.

    # @!attribute [rw] open_timeout
    #   @return [Integer] number of seconds to wait while opening a TCP
    #     connection to the server before raising a timeout error.
    #     Defaults to +30+.

    # @!attribute [rw] read_timeout
    #   @return [Integer] number of seconds to wait for a response from the
    #     server after the connection has been established before raising a
    #     timeout error. Defaults to +80+.

    # @!attribute [rw] max_network_retries
    #   @return [Integer] maximum number of automatic retries on transient
    #     network errors or rate-limit responses. Defaults to +1+.

    # @!attribute [rw] log_level
    #   @return [Integer, nil] the Logger severity level (e.g. Logger::DEBUG)
    #     used when a custom {#logger} is configured. Defaults to +nil+
    #     (logging disabled).

    # @!attribute [rw] logger
    #   @return [Logger, nil] a custom Logger instance to receive debug output.
    #     Defaults to +nil+.
    attr_accessor :api_key, :api_base, :api_version, :open_timeout, :read_timeout,
                  :max_network_retries, :log_level, :logger

    # Create a new Configuration with default values.
    #
    # @return [Configuration] a configuration object pre-populated with
    #   library defaults.
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

    # Support duplicating a configuration via +dup+.
    #
    # @param source [Configuration] the configuration being duplicated
    # @return [void]
    def initialize_dup(source)
      super
    end
  end
end
