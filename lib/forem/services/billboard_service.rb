module Forem
  module Services
    # Service for interacting with the Forem Billboards API.
    #
    # Billboards are display ads shown within Forem communities.
    # Access via {Client#billboards}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   billboards = client.billboards.list
    #   billboard  = client.billboards.retrieve(3)
    #
    # @see Billboard
    # @see https://developers.forem.com/api/v1
    class BillboardService < BaseService
      # List all billboards (display ads).
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Array<Billboard>] list of billboards
      #
      # @example
      #   client.billboards.list
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        Billboard.list(params, opts_with_requestor(opts))
      end

      # Create a new billboard.
      #
      # @param params [Hash] billboard attributes
      # @option params [String] :name internal name for the billboard
      # @option params [String] :body_markdown ad body in Markdown / HTML
      # @option params [String] :placement_area where to display the billboard
      # @option params [Boolean] :published whether the billboard is live
      # @option params [Integer] :organization_id organization this billboard
      #   belongs to
      # @param opts [Hash] per-request options
      # @return [Billboard] the newly created billboard
      #
      # @example
      #   client.billboards.create(
      #     name: "Summer Promo",
      #     body_markdown: "## Sale!\nUp to 50% off.",
      #     placement_area: "sidebar_left",
      #     published: true
      #   )
      #
      # @see https://developers.forem.com/api/v1
      def create(params = {}, opts = {})
        Billboard.create(params, opts_with_requestor(opts))
      end

      # Retrieve a single billboard by its numeric ID.
      #
      # @param id [Integer, String] the billboard ID
      # @param opts [Hash] per-request options
      # @return [Billboard] the billboard with the given ID
      #
      # @example
      #   client.billboards.retrieve(3)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, opts = {})
        Billboard.retrieve(id, opts_with_requestor(opts))
      end

      # Update an existing billboard.
      #
      # @param id [Integer, String] the billboard ID to update
      # @param params [Hash] billboard attributes to change
      # @option params [String] :name new internal name
      # @option params [String] :body_markdown new body content
      # @option params [Boolean] :published publish or unpublish the billboard
      # @param opts [Hash] per-request options
      # @return [Billboard] the updated billboard
      #
      # @example
      #   client.billboards.update(3, published: false)
      #
      # @see https://developers.forem.com/api/v1
      def update(id, params = {}, opts = {})
        Billboard.update(id, params, opts_with_requestor(opts))
      end
    end
  end
end
