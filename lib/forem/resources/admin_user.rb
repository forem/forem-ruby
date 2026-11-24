module Forem
  # Provides admin-level user management and synchronization for a Forem
  # instance.
  #
  # Requires super_admin privileges.
  #
  # Available operations:
  #   - +list+                         — GET /api/admin/users
  #   - +retrieve+                     — GET /api/admin/users/:id
  #   - +create+                       — POST /api/admin/users
  #   - +update+                       — PUT /api/admin/users/:id
  #   - +update_email+                 — PUT /api/admin/users/:id/email
  #   - +update_status+                — PUT /api/admin/users/:id/status
  #   - +update_notification_settings+ — PUT /api/admin/users/:id/notification_settings
  #   - +merge+                        — POST /api/admin/users/:id/merge
  #   - +notes+                        — GET /api/admin/users/:user_id/notes
  #   - +create_note+                  — POST /api/admin/users/:user_id/notes
  #   - +identities+                   — GET /api/admin/users/:user_id/identities
  #   - +link_identity+                — POST /api/admin/users/:user_id/identities
  #   - +bulk_link_identities+         — POST /api/admin/users/identities/bulk
  #   - +unlink_identity+              — DELETE /api/admin/users/:user_id/identities/:id
  #
  # @see Forem::User
  # @see https://developers.forem.com/api/v1
  class AdminUser < APIResource
    extend APIOperations::Create
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Save

    OBJECT_NAME = "admin_user"
    RESOURCE_PATH = "/api/admin/users"

    # List users via the admin API, with optional filtering and pagination.
    #
    # Sends a GET request to +/api/admin/users+. Unwraps the +{ "users" => [...] }+
    # envelope into a paginated {ListObject}.
    #
    # @param params [Hash] query parameters (+:email+, +:username+,
    #   +:identity_provider+, +:identity_uid+, +:page+, +:per_page+)
    # @param opts [Hash] per-request options
    # @return [Forem::ListObject<Forem::AdminUser>] paginated list of users
    def self.list(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, resource_path, params, opts)
      body = resp.parsed_body
      users = body.is_a?(Hash) ? (body["users"] || []) : Array(body)
      current_page = (body.is_a?(Hash) && body["page"]) || (params[:page] || params["page"] || 1).to_i
      per_page = (body.is_a?(Hash) && body["per_page"]) || (params[:per_page] || params["per_page"] || 25).to_i
      filters = params.reject { |k, _| %i[page per_page].include?(k.to_sym) }

      ListObject.new(
        data: users.map { |u| construct_from(u, requestor: requestor) },
        current_page: current_page,
        per_page: per_page,
        resource_class: self,
        filters: filters,
        requestor: requestor
      )
    end

    # Update a user's email address directly (bypasses Devise reconfirmation).
    #
    # Sends a PUT request to +/api/admin/users/:id/email+.
    #
    # @param user_id [Integer, String] the Forem user ID
    # @param email [String] the new email address
    # @param opts [Hash] per-request options
    # @return [ForemObject] +{ id:, email: }+
    def self.update_email(user_id, email:, **opts)
      requestor = opts[:requestor]
      resp = request(:put, "#{resource_path}/#{user_id}/email", { email: email }, opts)
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Update a user's moderation status.
    #
    # Sends a PUT request to +/api/admin/users/:id/status+.
    # Allowed statuses include +"Good standing"+, +"Suspended"+, +"Spam"+,
    # +"Warned"+, +"Comment Suspended"+, +"Trusted"+, +"Limited"+.
    #
    # @param user_id [Integer, String] the Forem user ID
    # @param status [String] new moderation status
    # @param note [String, nil] optional moderation note
    # @param opts [Hash] per-request options
    # @return [ForemObject] +{ id:, status: }+
    def self.update_status(user_id, status:, note: nil, **opts)
      requestor = opts[:requestor]
      payload = { status: status }
      payload[:note] = note unless note.nil?
      resp = request(:put, "#{resource_path}/#{user_id}/status", payload, opts)
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Merge another user account into this target user account.
    #
    # Sends a POST request to +/api/admin/users/:id/merge+.
    #
    # @param user_id [Integer, String] the surviving Forem user ID
    # @param merge_user_id [Integer, String] the duplicate user ID to merge and delete
    # @param opts [Hash] per-request options
    # @return [AdminUser] the surviving user record
    def self.merge(user_id, merge_user_id:, **opts)
      requestor = opts[:requestor]
      resp = request(:post, "#{resource_path}/#{user_id}/merge", { merge_user_id: merge_user_id }, opts)
      construct_from(resp.parsed_body, requestor: requestor)
    end

    # List admin moderation notes attached to a user.
    #
    # Sends a GET request to +/api/admin/users/:user_id/notes+.
    #
    # @param user_id [Integer, String] the Forem user ID
    # @param opts [Hash] per-request options
    # @return [Array<ForemObject>] admin notes ordered newest first
    def self.notes(user_id, **opts)
      requestor = opts[:requestor]
      resp = request(:get, "#{resource_path}/#{user_id}/notes", {}, opts)
      notes = resp.parsed_body["notes"] || []
      notes.map { |note| ForemObject.construct_from(note, requestor: requestor) }
    end

    # Attach an admin moderation note to a user.
    #
    # Sends a POST request to +/api/admin/users/:user_id/notes+.
    #
    # @param user_id [Integer, String] the Forem user ID
    # @param content [String] note content (required)
    # @param reason [String, nil] optional note reason (defaults to +"misc_note"+ server-side)
    # @param opts [Hash] per-request options
    # @return [ForemObject] the created note
    def self.create_note(user_id, content:, reason: nil, **opts)
      requestor = opts[:requestor]
      payload = { content: content }
      payload[:reason] = reason unless reason.nil?
      resp = request(:post, "#{resource_path}/#{user_id}/notes", payload, opts)
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Link an external provider identity to a user.
    #
    # @param user_id [Integer, String] the Forem user ID.
    # @param provider [String] the identity provider name.
    # @param uid [String] the provider's stable user identifier.
    # @param opts [Hash] per-request options.
    # @return [ForemObject] the linked identity.
    def self.link_identity(user_id, provider:, uid:, **opts)
      requestor = opts[:requestor]
      resp = request(
        :post,
        "#{resource_path}/#{user_id}/identities",
        { provider: provider, uid: uid },
        opts
      )
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Submit multiple external identity links in one request.
    #
    # @param provider [String] the identity provider shared by the identities.
    # @param identities [Array<Hash>] identity hashes containing +user_id+ and
    #   +uid+.
    # @param opts [Hash] per-request options.
    # @return [Array<ForemObject>] per-item results containing +user_id+,
    #   +status+, and an +error_code+ when that item fails.
    def self.bulk_link_identities(provider:, identities:, **opts)
      requestor = opts[:requestor]
      resp = request(
        :post,
        "#{resource_path}/identities/bulk",
        { provider: provider, identities: identities },
        opts
      )
      results = resp.parsed_body["results"] || []
      results.map do |result|
        ForemObject.construct_from(result, requestor: requestor)
      end
    end

    # List a user's linked external identities.
    #
    # @param user_id [Integer, String] the Forem user ID.
    # @param opts [Hash] per-request options.
    # @return [Array<ForemObject>] the user's linked identities.
    def self.identities(user_id, **opts)
      requestor = opts[:requestor]
      resp = request(:get, "#{resource_path}/#{user_id}/identities", {}, opts)
      identities = resp.parsed_body["identities"] || []
      identities.map do |identity|
        ForemObject.construct_from(identity, requestor: requestor)
      end
    end

    # Unlink an external identity from a user.
    #
    # @param user_id [Integer, String] the Forem user ID.
    # @param identity_id [Integer, String] the linked identity ID.
    # @param opts [Hash] per-request options.
    # @return [ForemObject, nil] the unlinked identity when returned by the
    #   API, otherwise +nil+ for an empty response.
    def self.unlink_identity(user_id, identity_id, **opts)
      requestor = opts[:requestor]
      resp = request(
        :delete,
        "#{resource_path}/#{user_id}/identities/#{identity_id}",
        {},
        opts
      )
      return nil unless resp.parsed_body

      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end

    # Update email notification settings for a user.
    #
    # @param user_id [Integer, String] the Forem user ID.
    # @param settings [Hash] notification setting columns to write, e.g.
    #   +{ email_newsletter: false, email_digest_periodic: false }+. Sent
    #   verbatim under the +notification_setting+ wrapper; the server owns
    #   which keys it accepts.
    # @param opts [Hash] per-request options.
    # @return [ForemObject] the updated notification setting.
    def self.update_notification_settings(user_id, settings:, **opts)
      requestor = opts[:requestor]
      resp = request(
        :put,
        "#{resource_path}/#{user_id}/notification_settings",
        { notification_setting: settings },
        opts
      )
      ForemObject.construct_from(resp.parsed_body, requestor: requestor)
    end
  end
end
