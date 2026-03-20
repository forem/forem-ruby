module Forem
  module Services
    class TagService < BaseService
      def list(params = {}, opts = {})
        Tag.list(params, opts_with_requestor(opts))
      end
    end
  end
end
