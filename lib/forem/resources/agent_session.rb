module Forem
  class AgentSession < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve

    OBJECT_NAME = "agent_session"
    RESOURCE_PATH = "/api/agent_sessions"

    def self.presign(params = {}, opts = {})
      resp = request(:post, "/api/agent_sessions/presign", params, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end

    def raw_url(opts = {})
      resp = request(:get, "#{resource_url}/raw_url", {}, opts)
      Forem::ForemObject.construct_from(resp.parsed_body)
    end
  end
end
