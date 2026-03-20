module Forem
  class Reaction < APIResource
    extend APIOperations::Create

    OBJECT_NAME = "reaction"
    RESOURCE_PATH = "/api/reactions"

    def self.toggle(params = {}, opts = {})
      resp = request(:post, "/api/reactions/toggle", params, opts)
      construct_from(resp.parsed_body)
    end
  end
end
