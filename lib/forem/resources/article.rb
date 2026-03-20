require "cgi"

module Forem
  class Article < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Save

    OBJECT_NAME = "article"
    RESOURCE_PATH = "/api/articles"

    def unpublish(opts = {})
      request(:put, "#{resource_url}/unpublish", {}, opts)
    end

    def self.me(params = {}, opts = {})
      resp = request(:get, "/api/articles/me", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    def self.me_published(params = {}, opts = {})
      resp = request(:get, "/api/articles/me/published", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    def self.me_unpublished(params = {}, opts = {})
      resp = request(:get, "/api/articles/me/unpublished", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    def self.me_all(params = {}, opts = {})
      resp = request(:get, "/api/articles/me/all", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    def self.latest(params = {}, opts = {})
      resp = request(:get, "/api/articles/latest", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    def self.search(params = {}, opts = {})
      resp = request(:get, "/api/articles/search", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item) }
    end

    def self.retrieve_by_path(username, slug, opts = {})
      resp = request(:get, "/api/articles/#{CGI.escape(username)}/#{CGI.escape(slug)}", {}, opts)
      construct_from(resp.parsed_body)
    end
  end
end
