module Forem
  class Video < APIResource
    extend APIOperations::List
    OBJECT_NAME = "video"
    RESOURCE_PATH = "/api/videos"
  end
end
