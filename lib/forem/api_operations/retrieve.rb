module Forem
  module APIOperations
    module Retrieve
      def retrieve(id, opts = {})
        resp = request(:get, "#{resource_path}/#{id}", {}, opts)
        construct_from(resp.parsed_body)
      end
    end
  end
end
