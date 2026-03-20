module Forem
  class Survey < APIResource
    extend APIOperations::List
    extend APIOperations::Retrieve

    OBJECT_NAME = "survey"
    RESOURCE_PATH = "/api/surveys"

    def responses(params = {}, opts = {})
      resp = request(:get, "#{resource_url}/responses", params, opts)
      (resp.parsed_body || []).map { |item| Forem::ForemObject.construct_from(item) }
    end
  end
end
