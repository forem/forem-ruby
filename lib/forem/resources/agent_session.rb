module Forem
  # Represents an agent session used for AI-assisted content workflows on Forem.
  #
  # Agent sessions track the state of an automated (AI) agent interacting
  # with Forem content. A presign step generates upload credentials before
  # session data is submitted. After creation, the raw asset URL for the
  # session can be retrieved via the +raw_url+ instance method.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/agent_sessions
  #   - +Create+   — POST /api/agent_sessions
  #   - +Retrieve+ — GET /api/agent_sessions/:id
  #
  # @example Get presigned upload credentials before creating a session
  #   presign = Forem::AgentSession.presign(filename: "session.json", mime_type: "application/json")
  #   puts presign.upload_url
  #
  # @example Create a new agent session
  #   session = Forem::AgentSession.create(
  #     agent_session: { prompt: "Summarise the top 5 articles today." }
  #   )
  #
  # @example Retrieve the raw asset URL for an existing session
  #   session = Forem::AgentSession.retrieve(99)
  #   puts session.raw_url.url
  #
  # @see https://developers.forem.com/api/v1
  class AgentSession < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve

    OBJECT_NAME = "agent_session"
    RESOURCE_PATH = "/api/agent_sessions"

    # Obtain presigned upload credentials for a new agent session asset.
    #
    # Sends a POST request to +/api/agent_sessions/presign+. The returned
    # object contains a signed upload URL and any required form fields needed
    # to upload the session file directly to object storage.
    #
    # @param params [Hash] request body
    # @option params [String] :filename the intended filename for the upload
    # @option params [String] :mime_type MIME type of the file being uploaded
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ForemObject] presign response containing upload URL and credentials
    # @example
    #   presign = Forem::AgentSession.presign(filename: "output.json", mime_type: "application/json")
    #   puts presign.upload_url
    # @see https://developers.forem.com/api/v1
    def self.presign(params = {}, opts = {})
      resp = request(:post, "/api/agent_sessions/presign", params, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end

    # Return the raw asset URL associated with this agent session.
    #
    # Sends a GET request to +/api/agent_sessions/:id/raw_url+.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::ForemObject] object containing the +url+ field with the raw asset URL
    # @example
    #   session = Forem::AgentSession.retrieve(99)
    #   puts session.raw_url.url
    # @see https://developers.forem.com/api/v1
    def raw_url(opts = {})
      resp = request(:get, "#{resource_url}/raw_url", {}, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end
  end
end
