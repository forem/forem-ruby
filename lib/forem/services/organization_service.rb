module Forem
  module Services
    class OrganizationService < BaseService
      def list(params = {}, opts = {})
        Organization.list(params, opts_with_requestor(opts))
      end

      def create(params = {}, opts = {})
        Organization.create(params, opts_with_requestor(opts))
      end

      def retrieve(id, opts = {})
        Organization.retrieve(id, opts_with_requestor(opts))
      end

      def update(id, params = {}, opts = {})
        Organization.update(id, params, opts_with_requestor(opts))
      end

      def delete(id, opts = {})
        Organization.delete(id, opts_with_requestor(opts))
      end
    end
  end
end
