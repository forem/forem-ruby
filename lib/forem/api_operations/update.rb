module Forem
  module APIOperations
    module Update
      def update(id, params = {}, opts = {})
        resp = request(:put, "#{resource_path}/#{id}", params, opts)
        construct_from(resp.parsed_body)
      end
    end
  end
end
