require "forem/version"
require "forem/configuration"
require "forem/errors"
require "forem/forem_response"
require "forem/connection_manager"
require "forem/api_requestor"

module Forem
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def api_key
      configuration.api_key
    end

    def api_key=(key)
      configuration.api_key = key
    end

    def api_base
      configuration.api_base
    end

    def api_base=(base)
      configuration.api_base = base
    end
  end
end
