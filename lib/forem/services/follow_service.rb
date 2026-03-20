module Forem
  module Services
    class FollowService < BaseService
      def list(params = {}, opts = {})
        Follow.list(params, opts_with_requestor(opts))
      end

      def create(params = {}, opts = {})
        Follow.create(params, opts_with_requestor(opts))
      end
    end
  end
end
