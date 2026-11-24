module Forem
  # Represents a custom static page on a Forem instance.
  #
  # Pages are CMS-style content pages on a Forem instance (e.g., about
  # pages, code of conduct).
  #
  # Pages are standalone content items (not articles) used for things like
  # an "About" page, a "Code of Conduct", or any other informational page
  # that lives at a dedicated URL on the community site. Full CRUD operations
  # are available, but managing pages requires an admin API key.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/pages
  #   - +Create+   — POST /api/pages
  #   - +Retrieve+ — GET /api/pages/:id
  #   - +Update+   — PUT /api/pages/:id
  #   - +Delete+   — instance-level delete (DELETE /api/pages/:id)
  #   - +Save+     — instance-level save (create or update)
  #
  # @example List all pages
  #   pages = client.pages.list
  #   pages.each { |p| puts "#{p.slug}: #{p.title}" }
  #
  # @example Create a new page (flat params — no +page:+ wrapper)
  #   page = client.pages.create(
  #     title: "About Us",
  #     slug: "about",
  #     body_markdown: "We are a community of developers.",
  #     is_top_level_path: true
  #   )
  #
  # @example Retrieve a page by ID
  #   page = client.pages.retrieve(3)
  #   puts page.title
  #
  # @example Delete a page
  #   page = client.pages.retrieve(3)
  #   page.delete
  #
  # @see https://developers.forem.com/api/v1
  class Page < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Delete
    include APIOperations::Save

    OBJECT_NAME = "page"
    RESOURCE_PATH = "/api/pages"

    # Preview rendered HTML for a page without persisting it.
    #
    # Sends a POST request to +/api/pages/preview+. Accepts flat or +page:+-wrapped
    # params (+:body_markdown+, +:body_html+, optional +:organization_id+).
    #
    # @param params [Hash] preview attributes
    # @param opts [Hash] per-request options
    # @return [Forem::ForemObject] object exposing +processed_html+
    def self.preview(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:post, "#{resource_path}/preview", params, opts)
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end
  end
end
