require "forem/version"
require "forem/configuration"
require "forem/errors"
require "forem/forem_response"
require "forem/connection_manager"
require "forem/util"
require "forem/forem_object"
require "forem/api_operations/request"
require "forem/api_operations/retrieve"
require "forem/api_operations/create"
require "forem/api_operations/update"
require "forem/api_operations/delete"
require "forem/api_operations/list"
require "forem/api_operations/save"
require "forem/list_object"
require "forem/api_resource"
require "forem/api_requestor"
require "forem/resources/article"
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

module Forem
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def api_key
      configuration.api_key
    end

    def api_key=(key)
      configuration.api_key = key
    end

    def api_base
      configuration.api_base
    end

    def api_base=(base)
      configuration.api_base = base
    end
  end
end
