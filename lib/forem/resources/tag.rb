module Forem
  # Represents a Forem tag used to categorize articles.
  #
  # Tags are keywords attached to articles that help readers discover related
  # content. Public endpoints allow listing tags (with optional exact +name:+
  # lookup) and listing supported tags; admin endpoints allow creating tags,
  # updating tag metadata, and managing tag moderators.
  #
  # Available operations:
  #   - +List+             — GET /api/tags (supports +page+, +per_page+, +name+)
  #   - +supported+        — GET /api/tags/supported
  #   - +Create+           — POST /api/tags (admin only)
  #   - +Update+           — PUT /api/tags/:id (admin only)
  #   - +Save+             — instance-level save (create or update)
  #   - +add_moderator+    — POST /api/tags/:id/moderators (admin only)
  #   - +remove_moderator+ — DELETE /api/tags/:id/moderators (admin only)
  #
  # @example List tags ordered by popularity
  #   tags = client.tags.list(per_page: 50)
  #   tags.data.each { |t| puts t.name }
  #
  # @example Look up a tag by exact name
  #   tags = client.tags.list(name: "ruby")
  #
  # @example List all supported tags in the current subforem
  #   supported = client.tags.supported
  #
  # @example Create or update a tag (admin only)
  #   tag = client.tags.create(name: "ruby", short_summary: "Ruby programming language", supported: true)
  #   client.tags.update(tag.id, bg_color_hex: "#cc342d", text_color_hex: "#ffffff")
  #
  # @example Manage tag moderators (admin only)
  #   client.tags.add_moderator(tag.id, username: "alice")
  #   client.tags.remove_moderator(tag.id, username: "alice")
  #
  # @see https://developers.forem.com/api/v1#/operations/getTags
  class Tag < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Update
    include APIOperations::Save

    OBJECT_NAME = "tag"
    RESOURCE_PATH = "/api/tags"

    # Return all tags supported in the current subforem (unpaginated).
    #
    # Sends a GET request to +/api/tags/supported+.
    #
    # @param params [Hash] optional query parameters
    # @param opts [Hash] per-request options
    # @return [Array<Forem::Tag>] supported tags ordered by popularity
    def self.supported(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "#{resource_path}/supported", params, opts)
      (resp.parsed_body || []).map { |item| construct_from(item, requestor: requestor) }
    end

    # Add a moderator to a tag (admin only).
    #
    # Sends a POST request to +/api/tags/:id/moderators+. Supply either
    # +:user_id+ or +:username+.
    #
    # @param id [Integer, String] the tag ID
    # @param params [Hash] moderator identifier (+:user_id+ or +:username+)
    # @param opts [Hash] per-request options
    # @return [Forem::ForemObject] moderator assignment (+tag_id+, +tag_name+,
    #   +user_id+, +username+)
    def self.add_moderator(id, params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:post, "#{resource_path}/#{id}/moderators", params, opts)
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Remove a moderator from a tag (admin only).
    #
    # Sends a DELETE request to +/api/tags/:id/moderators+. Supply either
    # +:user_id+ or +:username+.
    #
    # @param id [Integer, String] the tag ID
    # @param params [Hash] moderator identifier (+:user_id+ or +:username+)
    # @param opts [Hash] per-request options
    # @return [Forem::ForemObject] removed moderator assignment (+tag_id+,
    #   +tag_name+, +user_id+, +username+)
    def self.remove_moderator(id, params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:delete, "#{resource_path}/#{id}/moderators", params, opts)
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Add a moderator to this tag instance (admin only).
    #
    # @param params [Hash] moderator identifier (+:user_id+ or +:username+)
    # @param opts [Hash] per-request options
    # @return [Forem::ForemObject] moderator assignment
    def add_moderator(params = {}, opts = {})
      opts = opts.dup
      opts[:requestor] ||= @requestor
      resp = request(:post, "#{resource_url}/moderators", params, opts)
      ForemObject.construct_from(resp.parsed_body, requestor: opts[:requestor])
    end

    # Remove a moderator from this tag instance (admin only).
    #
    # @param params [Hash] moderator identifier (+:user_id+ or +:username+)
    # @param opts [Hash] per-request options
    # @return [Forem::ForemObject] removed moderator assignment
    def remove_moderator(params = {}, opts = {})
      opts = opts.dup
      opts[:requestor] ||= @requestor
      resp = request(:delete, "#{resource_url}/moderators", params, opts)
      ForemObject.construct_from(resp.parsed_body, requestor: opts[:requestor])
    end
  end
end
