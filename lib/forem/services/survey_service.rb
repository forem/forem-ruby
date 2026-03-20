module Forem
  module Services
    class SurveyService < BaseService
      def list(params = {}, opts = {})
        Survey.list(params, opts_with_requestor(opts))
      end

      def retrieve(id, opts = {})
        Survey.retrieve(id, opts_with_requestor(opts))
      end
    end
  end
end
