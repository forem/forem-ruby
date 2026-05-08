module Forem
  # Represents a curated list of recommended articles on a Forem instance.
  #
  # Curated lists of recommended articles. Used by admins to manage content
  # recommendations.
  #
  # RecommendedArticlesLists are editorial curation objects that group
  # articles for display in recommendation widgets or featured sections.
  # Full CRUD operations are supported. Managing these lists typically
  # requires an admin API key.
  #
  # Available operations (via mixins):
  #   - +List+     — GET /api/recommended_articles_lists
  #   - +Create+   — POST /api/recommended_articles_lists
  #   - +Retrieve+ — GET /api/recommended_articles_lists/:id
  #   - +Update+   — PUT /api/recommended_articles_lists/:id
  #   - +Save+     — instance-level save (create or update)
  #
  # @example List all recommended article lists
  #   lists = client.recommended_articles_lists.list
  #   lists.each { |l| puts l.name }
  #
  # @example Create a recommended articles list (flat params)
  #   list = client.recommended_articles_lists.create(
  #     name: "Top Ruby Articles",
  #     article_ids: [101, 202, 303]
  #   )
  #
  # @example Retrieve a list by ID and update it
  #   list = client.recommended_articles_lists.retrieve(1)
  #   list.name = "Updated Name"
  #   list.save
  #
  # @see https://developers.forem.com/api/v1
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
