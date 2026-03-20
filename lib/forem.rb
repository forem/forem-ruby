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
require "forem/services/base_service"
require "forem/services/article_service"
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
require "forem/client"

# Top-level namespace for the forem-ruby gem.
#
# This module provides convenience accessors that delegate to the global
# {Configuration} object and manages a shared {APIRequestor} instance used by
# all resource class methods.
#
# == Quick start
#
#   require "forem"
#
#   Forem.configure do |config|
#     config.api_key  = ENV["FOREM_API_KEY"]
#     config.api_base = "https://dev.to"   # default
#   end
#
#   articles = Forem::Article.list(per_page: 5)
#   articles.each { |a| puts a.title }
#
# @see Forem::Configuration for all available configuration options.
# @see https://developers.forem.com/api/v1 Forem API documentation
module Forem
  class << self
    # @!attribute [w] configuration
    #   @return [Configuration] the current global configuration object.
    #     Assign a fully-constructed {Configuration} instance to replace the
    #     default. Prefer {.configure} for selective updates.
    attr_writer :configuration

    # Return the global {Configuration} instance, creating it with defaults
    # if it does not yet exist.
    #
    # @return [Configuration] the current global configuration.
    #
    # @example
    #   Forem.configuration.api_base  #=> "https://dev.to"
    def configuration
      @configuration ||= Configuration.new
    end

    # Yield the global {Configuration} object for block-based setup.
    #
    # This is the recommended way to configure the library. Any changes made
    # inside the block take effect immediately and persist for the lifetime of
    # the process (or until {#reset_default_requestor!} / another
    # {#configure} call).
    #
    # @yield [config] the current {Configuration} instance.
    # @yieldparam config [Configuration] the configuration object to mutate.
    # @return [void]
    #
    # @example
    #   Forem.configure do |config|
    #     config.api_key             = ENV["FOREM_API_KEY"]
    #     config.api_base            = "https://dev.to"
    #     config.max_network_retries = 2
    #     config.open_timeout        = 10
    #     config.read_timeout        = 30
    #   end
    def configure
      yield(configuration)
    end

    # Return the API key from the global configuration.
    #
    # Shorthand for +Forem.configuration.api_key+.
    #
    # @return [String, nil] the configured API key, or +nil+ if not set.
    #
    # @example
    #   Forem.api_key  #=> "abc123"
    def api_key
      configuration.api_key
    end

    # Set the API key on the global configuration.
    #
    # Shorthand for +Forem.configuration.api_key = key+.
    #
    # @param key [String] the API key to use for authenticated requests.
    # @return [String] the assigned key.
    #
    # @example
    #   Forem.api_key = ENV["FOREM_API_KEY"]
    def api_key=(key)
      configuration.api_key = key
    end

    # Return the API base URL from the global configuration.
    #
    # Shorthand for +Forem.configuration.api_base+.
    #
    # @return [String] the base URL (e.g. <tt>"https://dev.to"</tt>).
    #
    # @example
    #   Forem.api_base  #=> "https://dev.to"
    def api_base
      configuration.api_base
    end

    # Set the API base URL on the global configuration.
    #
    # Shorthand for +Forem.configuration.api_base = base+. Useful when
    # targeting a self-hosted Forem instance instead of dev.to.
    #
    # @param base [String] the base URL of the Forem instance
    #   (e.g. <tt>"https://mycommunity.com"</tt>).
    # @return [String] the assigned base URL.
    #
    # @example
    #   Forem.api_base = "https://mycommunity.com"
    def api_base=(base)
      configuration.api_base = base
    end

    # Return the shared {APIRequestor} instance used by all resource methods.
    #
    # The requestor is lazily initialised on first access and reused for the
    # lifetime of the process. It picks up the current global {Configuration}
    # at creation time.
    #
    # Call {.reset_default_requestor!} to force a new requestor to be created
    # (e.g. after changing configuration).
    #
    # @return [APIRequestor] the shared requestor instance.
    #
    # @example
    #   Forem.default_requestor
    #   #=> #<Forem::APIRequestor ...>
    def default_requestor
      @default_requestor ||= APIRequestor.new
    end

    # Discard the cached default requestor, forcing a new one to be created
    # on the next call to {.default_requestor}.
    #
    # Call this after changing {Configuration} settings that affect request
    # behaviour (e.g. +api_key+ or +api_base+) if you are not using per-call
    # +:requestor+ overrides.
    #
    # @return [nil]
    #
    # @example Resetting after a configuration change
    #   Forem.api_key = "new_key"
    #   Forem.reset_default_requestor!
    #   # subsequent resource calls will use the new API key
    def reset_default_requestor!
      @default_requestor = nil
    end
  end
end
