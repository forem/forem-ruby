module Forem
  module APIOperations
    module Save
      def save(params = {}, **opts)
        resp = request(:put, resource_url, params, opts)
        self.class.construct_from(resp.parsed_body)
      end
    end
  end
end
