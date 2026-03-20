module Forem
  # Represents a custom static page on a Forem instance.
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
  #   pages = Forem::Page.list
  #   pages.data.each { |p| puts "#{p.slug}: #{p.title}" }
  #
  # @example Create a new page
  #   page = Forem::Page.create(
  #     page: {
  #       title: "About Us",
  #       slug: "about",
  #       body_markdown: "We are a community of developers.",
  #       is_top_level_path: true
  #     }
  #   )
  #
  # @example Retrieve a page by ID
  #   page = Forem::Page.retrieve(3)
  #   puts page.title
  #
  # @example Delete a page
  #   page = Forem::Page.retrieve(3)
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
  end
end
