module Forem
  class APIResource < ForemObject
    include APIOperations::Request

    def self.resource_path
      self::RESOURCE_PATH
    end

    def resource_url
      id = self["id"]
      raise InvalidRequestError.new("Could not determine resource ID") unless id
      "#{self.class.resource_path}/#{id}"
    end

    def refresh(opts = {})
      resp = request(:get, resource_url, {}, opts)
      @values = {}
      send(:update_attributes, resp.parsed_body)
      self
    end
  end
end
