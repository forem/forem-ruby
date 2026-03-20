module Forem
  module Services
    # Service for interacting with the Forem Organizations API.
    #
    # Access via {Client#organizations}. All methods inject the client's
    # requestor automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   orgs = client.organizations.list
    #   org  = client.organizations.retrieve(7)
    #
    # @see Organization
    # @see https://developers.forem.com/api/v1#tag/organizations
    class OrganizationService < BaseService
      # List all organizations.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Array<Organization>] list of organizations
      #
      # @example
      #   client.organizations.list(per_page: 25)
      #
      # @see https://developers.forem.com/api/v1#tag/organizations/operation/getOrganizations
      def list(params = {}, opts = {})
        Organization.list(params, opts_with_requestor(opts))
      end

      # Create a new organization.
      #
      # @param params [Hash] organization attributes
      # @option params [String] :name display name of the organization
      # @option params [String] :username unique username / slug
      # @option params [String] :summary short description
      # @option params [String] :url website URL
      # @option params [String] :location location string
      # @option params [String] :tech_stack technology stack description
      # @param opts [Hash] per-request options
      # @return [Organization] the newly created organization
      #
      # @example
      #   client.organizations.create(
      #     name: "Acme Corp",
      #     username: "acme",
      #     summary: "We make everything."
      #   )
      #
      # @see https://developers.forem.com/api/v1#tag/organizations/operation/createOrganization
      def create(params = {}, opts = {})
        Organization.create(params, opts_with_requestor(opts))
      end

      # Retrieve a single organization by its numeric ID.
      #
      # @param id [Integer, String] the organization ID
      # @param opts [Hash] per-request options
      # @return [Organization] the organization with the given ID
      #
      # @example
      #   client.organizations.retrieve(7)
      #
      # @see https://developers.forem.com/api/v1#tag/organizations/operation/getOrganizationById
      def retrieve(id, opts = {})
        Organization.retrieve(id, opts_with_requestor(opts))
      end

      # Update an existing organization.
      #
      # @param id [Integer, String] the organization ID to update
      # @param params [Hash] organization attributes to change
      # @option params [String] :name new display name
      # @option params [String] :summary new description
      # @option params [String] :url new website URL
      # @param opts [Hash] per-request options
      # @return [Organization] the updated organization
      #
      # @example
      #   client.organizations.update(7, summary: "Updated description.")
      #
      # @see https://developers.forem.com/api/v1#tag/organizations/operation/updateOrganization
      def update(id, params = {}, opts = {})
        Organization.update(id, params, opts_with_requestor(opts))
      end

      # Delete an organization.
      #
      # @param id [Integer, String] the organization ID to delete
      # @param opts [Hash] per-request options
      # @return [nil] returns nil on success
      #
      # @example
      #   client.organizations.delete(7)
      #
      # @see https://developers.forem.com/api/v1#tag/organizations/operation/deleteOrganization
      def delete(id, opts = {})
        Organization.delete(id, opts_with_requestor(opts))
      end
    end
  end
end
