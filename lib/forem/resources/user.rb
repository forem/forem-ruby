module Forem
  class User < APIResource
    extend APIOperations::Retrieve

    OBJECT_NAME = "user"
    RESOURCE_PATH = "/api/users"

    def self.me(opts = {})
      resp = request(:get, "/api/users/me", {}, opts)
      construct_from(resp.parsed_body)
    end

    def self.search(params = {}, opts = {})
      resp = request(:get, "/api/users/search", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    def unpublish(opts = {})
      request(:put, "#{resource_url}/unpublish", {}, opts)
    end

    def suspend(opts = {})
      request(:put, "#{resource_url}/suspend", {}, opts)
    end

    def unsuspend(opts = {})
      request(:delete, "#{resource_url}/suspend", {}, opts)
    end

    def add_limited(opts = {})
      request(:put, "#{resource_url}/limited", {}, opts)
    end

    def remove_limited(opts = {})
      request(:delete, "#{resource_url}/limited", {}, opts)
    end

    def add_spam(opts = {})
      request(:put, "#{resource_url}/spam", {}, opts)
    end

    def remove_spam(opts = {})
      request(:delete, "#{resource_url}/spam", {}, opts)
    end

    def add_trusted(opts = {})
      request(:put, "#{resource_url}/trusted", {}, opts)
    end

    def remove_trusted(opts = {})
      request(:delete, "#{resource_url}/trusted", {}, opts)
    end
  end
end
