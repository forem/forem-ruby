module Forem
  module Services
    class VideoService < BaseService
      def list(params = {}, opts = {})
        Video.list(params, opts_with_requestor(opts))
      end
    end
  end
end
