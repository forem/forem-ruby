module Forem
  module Services
    class FollowerService < BaseService
      def list(params = {}, opts = {})
        Follower.list(params, opts_with_requestor(opts))
      end
    end
  end
end
