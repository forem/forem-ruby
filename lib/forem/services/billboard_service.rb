module Forem
  module Services
    class BillboardService < BaseService
      def list(params = {}, opts = {})
        Billboard.list(params, opts_with_requestor(opts))
      end

      def create(params = {}, opts = {})
        Billboard.create(params, opts_with_requestor(opts))
      end

      def retrieve(id, opts = {})
        Billboard.retrieve(id, opts_with_requestor(opts))
      end

      def update(id, params = {}, opts = {})
        Billboard.update(id, params, opts_with_requestor(opts))
      end
    end
  end
end
