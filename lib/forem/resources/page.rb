module Forem
  class Page < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Delete
    include APIOperations::Save

    OBJECT_NAME = "page"
    RESOURCE_PATH = "/api/pages"
  end
end
