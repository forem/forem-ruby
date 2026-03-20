module Forem
  class Tag < APIResource
    extend APIOperations::List

    OBJECT_NAME = "tag"
    RESOURCE_PATH = "/api/tags"
  end
end
