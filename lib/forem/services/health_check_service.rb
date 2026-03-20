module Forem
  module Services
    class HealthCheckService < BaseService
      def app(opts = {})
        HealthCheck.app(opts_with_requestor(opts))
      end

      def database(opts = {})
        HealthCheck.database(opts_with_requestor(opts))
      end

      def cache(opts = {})
        HealthCheck.cache(opts_with_requestor(opts))
      end
    end
  end
end
