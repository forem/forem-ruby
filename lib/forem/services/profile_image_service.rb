module Forem
  module Services
    class ProfileImageService < BaseService
      def retrieve(username, opts = {})
        ProfileImage.retrieve(username, opts_with_requestor(opts))
      end
    end
  end
end
