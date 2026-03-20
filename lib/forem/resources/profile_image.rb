require "cgi"
module Forem
  class ProfileImage < APIResource
    OBJECT_NAME = "profile_image"
    RESOURCE_PATH = "/api/profile_images"

    def self.retrieve(username, opts = {})
      resp = request(:get, "#{resource_path}/#{CGI.escape(username)}", {}, opts)
      construct_from(resp.parsed_body)
    end
  end
end
