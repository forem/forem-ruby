require "cgi"

module Forem
  class Organization < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Delete
    include APIOperations::Save

    OBJECT_NAME = "organization"
    RESOURCE_PATH = "/api/organizations"

    def users(params = {}, opts = {})
      resp = request(:get, "#{resource_url}/users", params, opts)
      (resp.parsed_body || []).map { |item| Forem::User.construct_from(item) }
    end

    def articles(params = {}, opts = {})
      resp = request(:get, "#{resource_url}/articles", params, opts)
      (resp.parsed_body || []).map { |item| Forem::Article.construct_from(item) }
    end
  end
end
