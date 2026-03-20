module Forem
  class RecommendedArticlesList < APIResource
    extend APIOperations::Create
    extend APIOperations::List
    extend APIOperations::Retrieve
    extend APIOperations::Update
    include APIOperations::Save

    OBJECT_NAME = "recommended_articles_list"
    RESOURCE_PATH = "/api/recommended_articles_lists"
  end
end
