module Forem
  module Services
    class AdminUserService < BaseService
      def create(params = {}, opts = {})
        AdminUser.create(params, opts_with_requestor(opts))
      end
    end
  end
end
