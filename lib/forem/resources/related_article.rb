module Forem
  # Represents an article returned by the Related Articles discovery API.
  #
  # Sends a GET request to +/api/related_articles+. Requires authentication and
  # organization authorization (+organization_id+ parameter).
  #
  # Each returned item includes standard article attributes plus
  # +discovery_match+ and +discovery_rank+.
  #
  # @example Discover related articles for an organization
  #   articles = client.related_articles.list(organization_id: 7, q: "ruby")
  #   articles.each { |a| puts "#{a.title} (rank=#{a.discovery_rank})" }
  #
  # @see https://developers.forem.com/api/v1
  class RelatedArticle < APIResource
    extend APIOperations::List

    OBJECT_NAME = "related_article"
    RESOURCE_PATH = "/api/related_articles"
  end
end
