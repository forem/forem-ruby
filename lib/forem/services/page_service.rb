module Forem
  module Services
    # Service for interacting with the Forem Pages API.
    #
    # Pages are static landing pages within a Forem community.
    # Access via {Client#pages}. All methods inject the client's requestor
    # automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   pages = client.pages.list
    #   page  = client.pages.retrieve(10)
    #
    # @see Page
    # @see https://developers.forem.com/api/v1
    class PageService < BaseService
      # List all static pages.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Array<Page>] list of static pages
      #
      # @example
      #   client.pages.list
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        Page.list(params, opts_with_requestor(opts))
      end

      # Create a new static page.
      #
      # @param params [Hash] page attributes
      # @option params [String] :title page title
      # @option params [String] :slug URL slug (must be unique)
      # @option params [String] :body_markdown page body in Markdown
      # @option params [String] :body_html page body in HTML (alternative to
      #   Markdown)
      # @option params [Boolean] :is_top_level_path whether the page is
      #   accessible at the root path
      # @option params [String] :description short description / meta tag
      # @option params [String] :template page template name
      # @param opts [Hash] per-request options
      # @return [Page] the newly created page
      #
      # @example
      #   client.pages.create(
      #     title: "About Us",
      #     slug: "about",
      #     body_markdown: "## About\nWe are a community of developers."
      #   )
      #
      # @see https://developers.forem.com/api/v1
      def create(params = {}, opts = {})
        Page.create(params, opts_with_requestor(opts))
      end

      # Retrieve a single static page by its numeric ID.
      #
      # @param id [Integer, String] the page ID
      # @param opts [Hash] per-request options
      # @return [Page] the page with the given ID
      #
      # @example
      #   client.pages.retrieve(10)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, opts = {})
        Page.retrieve(id, opts_with_requestor(opts))
      end

      # Update an existing static page.
      #
      # @param id [Integer, String] the page ID to update
      # @param params [Hash] page attributes to change
      # @option params [String] :title new page title
      # @option params [String] :body_markdown new body in Markdown
      # @option params [String] :description new description
      # @param opts [Hash] per-request options
      # @return [Page] the updated page
      #
      # @example
      #   client.pages.update(10, title: "About Our Community")
      #
      # @see https://developers.forem.com/api/v1
      def update(id, params = {}, opts = {})
        Page.update(id, params, opts_with_requestor(opts))
      end

      # Delete a static page.
      #
      # @param id [Integer, String] the page ID to delete
      # @param opts [Hash] per-request options
      # @return [nil] returns nil on success
      #
      # @example
      #   client.pages.delete(10)
      #
      # @see https://developers.forem.com/api/v1
      def delete(id, opts = {})
        Page.delete(id, opts_with_requestor(opts))
      end
    end
  end
end
