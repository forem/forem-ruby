module Forem
  module Services
    class UserService < BaseService
      def retrieve(id, opts = {})
        User.retrieve(id, opts_with_requestor(opts))
      end

      def me(opts = {})
        User.me(opts_with_requestor(opts))
      end

      def search(params = {}, opts = {})
        User.search(params, opts_with_requestor(opts))
      end
    end
  end
end
