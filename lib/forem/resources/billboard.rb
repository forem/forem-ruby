module Forem
  class Billboard < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Save

    OBJECT_NAME = "billboard"
    RESOURCE_PATH = "/api/billboards"

    def unpublish(opts = {})
      request(:put, "#{resource_url}/unpublish", {}, opts)
    end
  end
end
