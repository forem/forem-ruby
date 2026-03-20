module Forem
  module Services
    class AnalyticsService < BaseService
      def totals(params = {}, opts = {})
        Analytics.totals(params, opts_with_requestor(opts))
      end

      def historical(params = {}, opts = {})
        Analytics.historical(params, opts_with_requestor(opts))
      end

      def past_day(params = {}, opts = {})
        Analytics.past_day(params, opts_with_requestor(opts))
      end

      def referrers(params = {}, opts = {})
        Analytics.referrers(params, opts_with_requestor(opts))
      end
    end
  end
end
