module Forem
  module Services
    # Service for interacting with the Forem Agent Sessions API.
    #
    # Agent sessions enable automated or AI-driven interactions with the Forem
    # platform. The presign endpoint provides a pre-signed URL for uploading
    # assets associated with a session.
    # Access via {Client#agent_sessions}. All methods inject the client's
    # requestor automatically so no additional configuration is required.
    #
    # @example
    #   client = Forem::Client.new("your-api-key")
    #   sessions = client.agent_sessions.list
    #   session  = client.agent_sessions.create(name: "My Agent")
    #
    # @see AgentSession
    # @see https://developers.forem.com/api/v1
    class AgentSessionService < BaseService
      # List all agent sessions.
      #
      # @param params [Hash] query parameters
      # @option params [Integer] :page page number (default: 1)
      # @option params [Integer] :per_page number of results per page
      # @param opts [Hash] per-request options
      # @return [Array<AgentSession>] list of agent sessions
      #
      # @example
      #   client.agent_sessions.list
      #
      # @see https://developers.forem.com/api/v1
      def list(params = {}, opts = {})
        AgentSession.list(params, opts_with_requestor(opts))
      end

      # Create a new agent session.
      #
      # @param params [Hash] session attributes
      # @option params [String] :name display name for the session
      # @param opts [Hash] per-request options
      # @return [AgentSession] the newly created agent session
      #
      # @example
      #   session = client.agent_sessions.create(name: "Content Generation Bot")
      #
      # @see https://developers.forem.com/api/v1
      def create(params = {}, opts = {})
        AgentSession.create(params, opts_with_requestor(opts))
      end

      # Retrieve a single agent session by its numeric ID.
      #
      # @param id [Integer, String] the session ID
      # @param opts [Hash] per-request options
      # @return [AgentSession] the session with the given ID
      #
      # @example
      #   client.agent_sessions.retrieve(14)
      #
      # @see https://developers.forem.com/api/v1
      def retrieve(id, opts = {})
        AgentSession.retrieve(id, opts_with_requestor(opts))
      end

      # Obtain a pre-signed URL for uploading a file associated with an agent
      # session.
      #
      # @param params [Hash] presign request parameters
      # @option params [String] :filename name of the file to upload
      # @option params [String] :mime_type MIME type of the file
      # @param opts [Hash] per-request options
      # @return [AgentSession] object containing the pre-signed upload URL and
      #   related metadata
      #
      # @example
      #   presign_data = client.agent_sessions.presign(
      #     filename: "image.png",
      #     mime_type: "image/png"
      #   )
      #   puts presign_data.upload_url
      #
      # @see https://developers.forem.com/api/v1
      def presign(params = {}, opts = {})
        AgentSession.presign(params, opts_with_requestor(opts))
      end
    end
  end
end
