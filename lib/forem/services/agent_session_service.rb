module Forem
  module Services
    class AgentSessionService < BaseService
      def list(params = {}, opts = {})
        AgentSession.list(params, opts_with_requestor(opts))
      end

      def create(params = {}, opts = {})
        AgentSession.create(params, opts_with_requestor(opts))
      end

      def retrieve(id, opts = {})
        AgentSession.retrieve(id, opts_with_requestor(opts))
      end

      def presign(params = {}, opts = {})
        AgentSession.presign(params, opts_with_requestor(opts))
      end
    end
  end
end
