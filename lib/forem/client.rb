module Forem
  # Client for making authenticated requests to the Forem API.
  #
  # Use this when you need per-instance configuration (e.g., different API keys
  # for different Forem instances). For simple single-instance use, configure
  # the global {Forem.api_key} instead.
  #
  # @example Basic client usage
  #   client = Forem::Client.new("your-api-key")
  #   articles = client.articles.list(per_page: 10)
  #
  # @example Connecting to a custom Forem instance
  #   client = Forem::Client.new("key", api_base: "https://my-forem.com")
  #   user = client.users.me
  #
  # @see https://developers.forem.com/api/v1
  class Client
    # @return [Configuration] the configuration object for this client
    attr_reader :config

    # @return [APIRequestor] the requestor used to make HTTP calls
    attr_reader :requestor

    # Create a new Forem API client.
    #
    # @param api_key [String] your Forem API key
    # @param api_base [String] base URL for the Forem API (default: "https://dev.to")
    # @param opts [Hash] additional configuration options passed to {Configuration}
    # @return [Client] a new client instance
    #
    # @example
    #   client = Forem::Client.new("my-secret-api-key")
    #
    # @example With a custom Forem instance
    #   client = Forem::Client.new("my-key", api_base: "https://community.example.com")
    def initialize(api_key, api_base: "https://dev.to", **opts)
      @config = Configuration.new
      @config.api_key = api_key
      @config.api_base = api_base
      opts.each { |k, v| @config.send(:"#{k}=", v) if @config.respond_to?(:"#{k}=") }
      @requestor = APIRequestor.new(config: @config)
    end

    # Access the Articles API.
    #
    # @return [Services::ArticleService] the articles service
    # @see https://developers.forem.com/api/v1#tag/articles
    #
    # @example
    #   client.articles.list(per_page: 5)
    #   client.articles.retrieve(12345)
    def articles;                    @articles ||= Services::ArticleService.new(@requestor); end

    # Access the Users API.
    #
    # @return [Services::UserService] the users service
    # @see https://developers.forem.com/api/v1#tag/users
    #
    # @example
    #   client.users.me
    #   client.users.retrieve(42)
    def users;                       @users ||= Services::UserService.new(@requestor); end

    # Access the Comments API.
    #
    # @return [Services::CommentService] the comments service
    # @see https://developers.forem.com/api/v1#tag/comments
    #
    # @example
    #   client.comments.list(a_id: 123)
    #   client.comments.retrieve("abc123")
    def comments;                    @comments ||= Services::CommentService.new(@requestor); end

    # Access the Organizations API.
    #
    # @return [Services::OrganizationService] the organizations service
    # @see https://developers.forem.com/api/v1#tag/organizations
    #
    # @example
    #   client.organizations.list
    #   client.organizations.retrieve(7)
    def organizations;               @organizations ||= Services::OrganizationService.new(@requestor); end

    # Access the Tags API.
    #
    # @return [Services::TagService] the tags service
    # @see https://developers.forem.com/api/v1#tag/tags
    #
    # @example
    #   client.tags.list(per_page: 20)
    def tags;                        @tags ||= Services::TagService.new(@requestor); end

    # Access the Follows API.
    #
    # @return [Services::FollowService] the follows service
    # @see https://developers.forem.com/api/v1#tag/follows
    #
    # @example
    #   client.follows.list
    #   client.follows.create(followable_type: "User", followable_id: 99)
    def follows;                     @follows ||= Services::FollowService.new(@requestor); end

    # Access the Followers API.
    #
    # @return [Services::FollowerService] the followers service
    # @see https://developers.forem.com/api/v1#tag/followers
    #
    # @example
    #   client.followers.list(per_page: 50)
    def followers;                   @followers ||= Services::FollowerService.new(@requestor); end

    # Access the Reading List API.
    #
    # @return [Services::ReadingListService] the reading list service
    # @see https://developers.forem.com/api/v1#tag/readinglist
    #
    # @example
    #   client.reading_list.list(page: 1)
    def reading_list;                @reading_list ||= Services::ReadingListService.new(@requestor); end

    # Access the Podcast Episodes API.
    #
    # @return [Services::PodcastEpisodeService] the podcast episodes service
    # @see https://developers.forem.com/api/v1#tag/podcast-episodes
    #
    # @example
    #   client.podcast_episodes.list(username: "someshow")
    def podcast_episodes;            @podcast_episodes ||= Services::PodcastEpisodeService.new(@requestor); end

    # Access the Videos API.
    #
    # @return [Services::VideoService] the videos service
    # @see https://developers.forem.com/api/v1#tag/videos
    #
    # @example
    #   client.videos.list(page: 1)
    def videos;                      @videos ||= Services::VideoService.new(@requestor); end

    # Access the Profile Images API.
    #
    # @return [Services::ProfileImageService] the profile images service
    # @see https://developers.forem.com/api/v1#tag/profile-images
    #
    # @example
    #   client.profile_images.retrieve("jsmith")
    def profile_images;              @profile_images ||= Services::ProfileImageService.new(@requestor); end

    # Access the Billboards API.
    #
    # @return [Services::BillboardService] the billboards service
    # @see https://developers.forem.com/api/v1#tag/billboards
    #
    # @example
    #   client.billboards.list
    #   client.billboards.retrieve(3)
    def billboards;                  @billboards ||= Services::BillboardService.new(@requestor); end

    # Access the Pages API.
    #
    # @return [Services::PageService] the pages service
    # @see https://developers.forem.com/api/v1#tag/pages
    #
    # @example
    #   client.pages.list
    #   client.pages.create(title: "About", slug: "about", body_markdown: "...")
    def pages;                       @pages ||= Services::PageService.new(@requestor); end

    # Access the Segments API.
    #
    # @return [Services::SegmentService] the segments service
    # @see https://developers.forem.com/api/v1#tag/segments
    #
    # @example
    #   client.segments.list
    #   client.segments.retrieve(5)
    def segments;                    @segments ||= Services::SegmentService.new(@requestor); end

    # Access the Reactions API.
    #
    # @return [Services::ReactionService] the reactions service
    # @see https://developers.forem.com/api/v1#tag/reactions
    #
    # @example
    #   client.reactions.create(reactable_type: "Article", reactable_id: 1, category: "like")
    #   client.reactions.toggle(reactable_type: "Article", reactable_id: 1, category: "like")
    def reactions;                   @reactions ||= Services::ReactionService.new(@requestor); end

    # Access the Recommended Articles Lists API.
    #
    # @return [Services::RecommendedArticlesListService] the recommended articles lists service
    # @see https://developers.forem.com/api/v1#tag/articles
    #
    # @example
    #   client.recommended_articles_lists.list
    #   client.recommended_articles_lists.retrieve(2)
    def recommended_articles_lists;  @recommended_articles_lists ||= Services::RecommendedArticlesListService.new(@requestor); end

    # Access the Agent Sessions API.
    #
    # @return [Services::AgentSessionService] the agent sessions service
    # @see https://developers.forem.com/api/v1
    #
    # @example
    #   client.agent_sessions.list
    #   client.agent_sessions.presign(filename: "upload.jpg")
    def agent_sessions;              @agent_sessions ||= Services::AgentSessionService.new(@requestor); end

    # Access the Surveys API.
    #
    # @return [Services::SurveyService] the surveys service
    # @see https://developers.forem.com/api/v1
    #
    # @example
    #   client.surveys.list
    #   client.surveys.retrieve(8)
    def surveys;                     @surveys ||= Services::SurveyService.new(@requestor); end

    # Access the Analytics API.
    #
    # @return [Services::AnalyticsService] the analytics service
    # @see https://developers.forem.com/api/v1#tag/analytics
    #
    # @example
    #   client.analytics.totals(username: "jsmith")
    #   client.analytics.historical(username: "jsmith", start: "2024-01-01")
    def analytics;                   @analytics ||= Services::AnalyticsService.new(@requestor); end

    # Access the Health Checks API.
    #
    # @return [Services::HealthCheckService] the health check service
    # @see https://developers.forem.com/api/v1#tag/health-checks
    #
    # @example
    #   client.health_checks.app
    #   client.health_checks.database
    def health_checks;               @health_checks ||= Services::HealthCheckService.new(@requestor); end

    # Access the Admin Users API.
    #
    # @return [Services::AdminUserService] the admin users service
    # @see https://developers.forem.com/api/v1#tag/users
    #
    # @example
    #   client.admin_users.create(email: "new@example.com", name: "New User")
    def admin_users;                 @admin_users ||= Services::AdminUserService.new(@requestor); end

    # Access the Trends API.
    #
    # @return [Services::TrendService] the trends service
    #
    # @example
    #   client.trends.list
    def trends;                      @trends ||= Services::TrendService.new(@requestor); end

    # Access the Concepts API.
    #
    # @return [Services::ConceptService] the concepts service
    #
    # @example
    #   client.concepts.list
    def concepts;                    @concepts ||= Services::ConceptService.new(@requestor); end

    # Access the Admin Concepts API.
    #
    # @return [Services::AdminConceptService] the admin concepts service
    #
    # @example
    #   client.admin_concepts.list
    def admin_concepts;              @admin_concepts ||= Services::AdminConceptService.new(@requestor); end

    # Access the Admin Request Redirects API.
    #
    # @return [Services::RequestRedirectService] the request redirects service
    #
    # @example
    #   client.request_redirects.list
    def request_redirects;           @request_redirects ||= Services::RequestRedirectService.new(@requestor); end
  end
end
