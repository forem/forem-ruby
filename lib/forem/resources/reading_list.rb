module Forem
  class ReadingList < APIResource
    extend APIOperations::List
    OBJECT_NAME = "reading_list"
    RESOURCE_PATH = "/api/readinglist"
  end
end
