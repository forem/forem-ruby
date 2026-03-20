module Forem
  module Services
    class ReadingListService < BaseService
      def list(params = {}, opts = {})
        ReadingList.list(params, opts_with_requestor(opts))
      end
    end
  end
end
