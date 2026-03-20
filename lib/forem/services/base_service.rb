module Forem
  module Services
    class BaseService
      def initialize(requestor)
        @requestor = requestor
      end

      private

      def opts_with_requestor(opts)
        opts.merge(requestor: @requestor)
      end
    end
  end
end
