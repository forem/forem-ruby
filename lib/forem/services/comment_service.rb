module Forem
  module Services
    class CommentService < BaseService
      def list(params = {}, opts = {})
        Comment.list(params, opts_with_requestor(opts))
      end

      def retrieve(id, opts = {})
        Comment.retrieve(id, opts_with_requestor(opts))
      end
    end
  end
end
