module Forem
  # Represents a Forem organization (a group account that can publish articles).
  #
  # Organizations are team or company accounts on a Forem instance. They
  # support full CRUD operations and expose sub-collection endpoints for
  # listing their members and articles. Organizations can be retrieved by
  # either numeric ID or username slug.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/organizations  (default: 10 per page)
  #   - +Create+   — POST /api/organizations
  #   - +Retrieve+ — GET /api/organizations/:id_or_username
  #   - +Update+   — PUT /api/organizations/:id
  #   - +Delete+   — instance-level delete
  #   - +Save+     — instance-level save (create or update)
  #
  # @example List all organizations
  #   orgs = client.organizations.list(per_page: 20)
  #   orgs.data.each { |o| puts o.name }
  #
  # @example Create an organization
  #   org = client.organizations.create(
  #     organization: { name: "Acme Corp", summary: "We make things." }
  #   )
  #
  # @example Retrieve an organization by username
  #   org = client.organizations.retrieve("acme-corp")
  #   puts org.name
  #
  # @see https://developers.forem.com/api/v1#/operations/getOrganizations
  # @see https://developers.forem.com/api/v1#/operations/createOrganization
  class Organization < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Delete
    include APIOperations::Save

    OBJECT_NAME = "organization"
    RESOURCE_PATH = "/api/organizations"

    # Return the members of this organization.
    #
    # Sends a GET request to +/api/organizations/:id/users+.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::User>] members of the organization
    # @example
    #   org = client.organizations.retrieve("acme-corp")
    #   org.users.each { |u| puts u.username }
    # @see https://developers.forem.com/api/v1#/operations/getOrgUsers
    def users(params = {}, opts = {})
      resp = request(:get, "#{resource_url}/users", params, opts)
      (resp.parsed_body || []).map { |item| Forem::User.construct_from(item) }
    end

    # Return articles published under this organization.
    #
    # Sends a GET request to +/api/organizations/:id/articles+.
    #
    # @param params [Hash] query parameters
    # @option params [Integer] :page page number (default: 1)
    # @option params [Integer] :per_page number of results per page (default: 30)
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Array<Forem::Article>] articles belonging to the organization
    # @example
    #   org = client.organizations.retrieve("acme-corp")
    #   org.articles.each { |a| puts a.title }
    # @see https://developers.forem.com/api/v1
    def articles(params = {}, opts = {})
      resp = request(:get, "#{resource_url}/articles", params, opts)
      (resp.parsed_body || []).map { |item| Forem::Article.construct_from(item) }
    end
  end
end
