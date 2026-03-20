module Forem
  class Segment < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    include APIOperations::Delete

    OBJECT_NAME = "segment"
    RESOURCE_PATH = "/api/segments"

    def users(params = {}, opts = {})
      resp = request(:get, "#{resource_url}/users", params, opts)
      (resp.parsed_body || []).map { |item| Forem::ForemObject.construct_from(item) }
    end

    def add_users(params = {}, opts = {})
      request(:put, "#{resource_url}/add_users", params, opts)
    end

    def remove_users(params = {}, opts = {})
      request(:put, "#{resource_url}/remove_users", params, opts)
    end
  end
end
