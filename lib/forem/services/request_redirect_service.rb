module Forem
  module Services
    # Service for interacting with the Forem Admin Request Redirects API.
    #
    # Request redirects power organization custom domains: a request for
    # +request_domain+ at path +original_url+ is redirected to
    # +destination_url+. These endpoints require an API key with admin-level
    # privileges. Access via {Client#request_redirects}. All methods inject
    # the client's requestor automatically so no additional configuration is
    # required.
    #
    # The underlying API requires create/update request bodies to be wrapped
    # in a +request_redirect:+ key. This service accepts flat attribute
    # hashes and wraps them for you, so callers never need to think about the
    # wrapper.
    #
    # @example
    #   client = Forem::Client.new("admin-api-key")
    #   redirect = client.request_redirects.create(
    #     original_url: "/old",
    #     destination_url: "https://example.com/new",
    #     request_domain: "example.com"
    #   )
    #
    # @see RequestRedirect
    # @see https://developers.forem.com/api/v1
    class RequestRedirectService < BaseService
      # List all request redirects, most recently created first.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      #   (default: 50, maximum: 100)
      # @param opts [Hash] per-request options
      # @return [Forem::ListObject<RequestRedirect>] paginated list of request redirects
      #
      # @example
      #   client.request_redirects.list(per_page: 25)
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        RequestRedirect.list(params, opts_with_requestor(opts))
      end

      # Retrieve a single request redirect by its numeric ID.
      #
      # @param id [Integer, String] the request redirect ID
      # @param opts [Hash] per-request options
      # @return [RequestRedirect] the request redirect with the given ID
      #
      # @example
      #   client.request_redirects.retrieve(7)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, opts = {})
        RequestRedirect.retrieve(id, opts_with_requestor(opts))
      end

      # Create a new request redirect.
      #
      # @param params [Hash] request redirect attributes (flat — no
      #   +request_redirect:+ wrapper needed, this method adds it for you)
      # @option params [String] :original_url the incoming request path;
      #   must start with +/+
      # @option params [String] :destination_url the fully-qualified
      #   HTTP/HTTPS URL to redirect to
      # @option params [String] :request_domain the domain the redirect
      #   applies to
      # @param opts [Hash] per-request options
      # @return [RequestRedirect] the newly created request redirect
      #
      # @example
      #   client.request_redirects.create(
      #     original_url: "/old",
      #     destination_url: "https://example.com/new",
      #     request_domain: "example.com"
      #   )
      #
      # @see https://developers.forem.com/api/v1
      def create(params = {}, opts = {})
        RequestRedirect.create({ request_redirect: params }, opts_with_requestor(opts))
      end

      # Update an existing request redirect.
      #
      # @param id [Integer, String] the request redirect ID to update
      # @param params [Hash] request redirect attributes to change (flat —
      #   no +request_redirect:+ wrapper needed, this method adds it for you)
      # @option params [String] :original_url new incoming request path
      # @option params [String] :destination_url new destination URL
      # @option params [String] :request_domain new request domain
      # @param opts [Hash] per-request options
      # @return [RequestRedirect] the updated request redirect
      #
      # @example
      #   client.request_redirects.update(7, destination_url: "https://example.com/newer")
      #
      # @see https://developers.forem.com/api/v1
      def update(id, params = {}, opts = {})
        RequestRedirect.update(id, { request_redirect: params }, opts_with_requestor(opts))
      end

      # Delete a request redirect.
      #
      # @param id [Integer, String] the request redirect ID to delete
      # @param opts [Hash] per-request options
      # @return [nil] returns nil on success (the API responds with 204 No Content)
      #
      # @example
      #   client.request_redirects.delete(7)
      #
      # @see https://developers.forem.com/api/v1
      def delete(id, opts = {})
        RequestRedirect.delete(id, opts_with_requestor(opts))
      end
    end
  end
end
