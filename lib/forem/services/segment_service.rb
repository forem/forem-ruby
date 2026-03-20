module Forem
  module Services
    class SegmentService < BaseService
      def list(params = {}, opts = {})
        Segment.list(params, opts_with_requestor(opts))
      end

      def create(params = {}, opts = {})
        Segment.create(params, opts_with_requestor(opts))
      end

      def retrieve(id, opts = {})
        Segment.retrieve(id, opts_with_requestor(opts))
      end

      def delete(id, opts = {})
        Segment.delete(id, opts_with_requestor(opts))
      end
    end
  end
end
