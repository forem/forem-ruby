module Forem
  module APIOperations
    module Create
      def create(params = {}, opts = {})
        resp = request(:post, resource_path, params, opts)
        construct_from(resp.parsed_body)
      end
    end
  end
end
