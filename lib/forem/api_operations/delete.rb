module Forem
  module APIOperations
    module Delete
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def delete(id, opts = {})
          resp = request(:delete, "#{resource_path}/#{id}", {}, opts)
          resp.parsed_body ? construct_from(resp.parsed_body) : nil
        end
      end

      def delete(opts = {})
        resp = request(:delete, resource_url, {}, opts)
        resp.parsed_body ? self.class.construct_from(resp.parsed_body) : self
      end
    end
  end
end
