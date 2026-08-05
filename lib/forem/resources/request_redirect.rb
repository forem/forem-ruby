module Forem
  # Represents a request redirect used to map legacy or custom-domain paths
  # to a destination URL.
  #
  # Request redirects power organization custom domains: when a request
  # comes in for +request_domain+ at path +original_url+, Forem redirects
  # the visitor to +destination_url+. Managing request redirects is an
  # admin-only operation and requires an admin API key.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/admin/request_redirects
  #   - +Create+   — POST /api/admin/request_redirects
  #   - +Retrieve+ — GET /api/admin/request_redirects/:id
  #   - +Update+   — PUT /api/admin/request_redirects/:id
  #   - +Delete+   — instance-level delete (DELETE /api/admin/request_redirects/:id)
  #   - +Save+     — instance-level save (create or update)
  #
  # == RequestRedirect Fields
  #
  # - +original_url+ (String, required) — the incoming request path; must
  #   start with +/+ and is unique per +request_domain+
  # - +destination_url+ (String, required) — the fully-qualified HTTP/HTTPS
  #   URL to redirect to
  # - +request_domain+ (String, required) — the domain the redirect applies
  #   to; normalized to lowercase by the server
  #
  # The create/update endpoints require request bodies wrapped in a
  # +request_redirect:+ key (the API uses strong parameters with
  # +params.require(:request_redirect)+), so callers of the class methods
  # here must supply that wrapper explicitly. {Forem::Services::RequestRedirectService}
  # handles the wrapping automatically for the friendlier, flat-params
  # service interface.
  #
  # @example List all request redirects
  #   redirects = client.request_redirects.list
  #   redirects.each { |r| puts "#{r.request_domain}#{r.original_url} -> #{r.destination_url}" }
  #
  # @example Create a request redirect (params must be wrapped in +request_redirect:+)
  #   redirect = Forem::RequestRedirect.create(
  #     { request_redirect: { original_url: "/old", destination_url: "https://example.com/new", request_domain: "example.com" } },
  #     requestor: client.requestor
  #   )
  #
  # @example Retrieve a request redirect by ID
  #   redirect = client.request_redirects.retrieve(7)
  #   puts redirect.destination_url
  #
  # @see https://developers.forem.com/api/v1
  class RequestRedirect < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Delete
    include APIOperations::Save

    OBJECT_NAME = "request_redirect"
    RESOURCE_PATH = "/api/admin/request_redirects"
  end
end
