module Forem
  module APIOperations
    module Request
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def request(method, path, params = {}, opts = {})
          requestor = opts.delete(:requestor) || Forem.default_requestor
          requestor.request(method, path, params, opts)
        end
      end

      def request(method, path, params = {}, opts = {})
        self.class.request(method, path, params, opts)
      end
    end
  end
end
