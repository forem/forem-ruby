require "forem/version"
require "forem/configuration"
require "forem/errors"
require "forem/forem_response"
require "forem/connection_manager"
require "forem/util"
require "forem/api_operations/request"
require "forem/list_object"
require "forem/forem_object"
require "forem/api_operations/retrieve"
require "forem/api_operations/create"
require "forem/api_operations/update"
require "forem/api_operations/delete"
require "forem/api_operations/list"
require "forem/api_operations/save"
require "forem/api_resource"
require "forem/api_requestor"
require "forem/resources/article"
require "forem/resources/badge"
require "forem/resources/badge_achievement"
require "forem/resources/user"
require "forem/resources/comment"
require "forem/resources/organization"
require "forem/resources/tag"
require "forem/resources/follow"
require "forem/resources/follower"
require "forem/resources/reading_list"
require "forem/resources/podcast_episode"
require "forem/resources/video"
require "forem/resources/profile_image"
require "forem/resources/billboard"
require "forem/resources/page"
require "forem/resources/segment"
require "forem/resources/reaction"
require "forem/resources/recommended_articles_list"
require "forem/resources/agent_session"
require "forem/resources/survey"
require "forem/resources/analytics"
require "forem/resources/health_check"
require "forem/resources/admin_user"
require "forem/resources/trend"
require "forem/resources/concept"
require "forem/resources/admin_concept"
require "forem/resources/request_redirect"
require "forem/resources/event"
require "forem/services/base_service"
require "forem/services/article_service"
require "forem/services/badge_service"
require "forem/services/badge_achievement_service"
require "forem/services/user_service"
require "forem/services/comment_service"
require "forem/services/organization_service"
require "forem/services/tag_service"
require "forem/services/follow_service"
require "forem/services/follower_service"
require "forem/services/reading_list_service"
require "forem/services/podcast_episode_service"
require "forem/services/video_service"
require "forem/services/profile_image_service"
require "forem/services/billboard_service"
require "forem/services/page_service"
require "forem/services/segment_service"
require "forem/services/reaction_service"
require "forem/services/recommended_articles_list_service"
require "forem/services/agent_session_service"
require "forem/services/survey_service"
require "forem/services/analytics_service"
require "forem/services/health_check_service"
require "forem/services/admin_user_service"
require "forem/services/trend_service"
require "forem/services/concept_service"
require "forem/services/admin_concept_service"
require "forem/services/request_redirect_service"
require "forem/services/event_service"
require "forem/client"

# Top-level namespace for the forem-ruby gem.
#
# All API access goes through {Forem::Client}. The library does not maintain
# any global state — each {Client} instance carries its own configuration and
# {APIRequestor}, so multiple clients (e.g. for different Forem instances or
# different API keys) can coexist in the same process without interfering
# with each other.
#
# == Quick start
#
#   require "forem"
#
#   client = Forem::Client.new(ENV["FOREM_API_KEY"])
#
#   articles = client.articles.list(per_page: 5)
#   articles.each { |a| puts a.title }
#
# @see Forem::Client
# @see https://developers.forem.com/api/v1 Forem API documentation
module Forem
end
