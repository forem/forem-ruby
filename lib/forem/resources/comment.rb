module Forem
  class Comment < APIResource
    extend APIOperations::List
    extend APIOperations::Retrieve

    OBJECT_NAME = "comment"
    RESOURCE_PATH = "/api/comments"
  end
end
