module Forem
  module Services
    class PageService < BaseService
      def list(params = {}, opts = {})
        Page.list(params, opts_with_requestor(opts))
      end

      def create(params = {}, opts = {})
        Page.create(params, opts_with_requestor(opts))
      end

      def retrieve(id, opts = {})
        Page.retrieve(id, opts_with_requestor(opts))
      end

      def update(id, params = {}, opts = {})
        Page.update(id, params, opts_with_requestor(opts))
      end

      def delete(id, opts = {})
        Page.delete(id, opts_with_requestor(opts))
      end
    end
  end
end
