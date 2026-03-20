module Forem
  class Client
    attr_reader :config, :requestor

    def initialize(api_key, api_base: "https://dev.to", **opts)
      @config = Configuration.new
      @config.api_key = api_key
      @config.api_base = api_base
      opts.each { |k, v| @config.send(:"#{k}=", v) if @config.respond_to?(:"#{k}=") }
      @requestor = APIRequestor.new(config: @config)
    end

    def articles;                    @articles ||= Services::ArticleService.new(@requestor); end
    def users;                       @users ||= Services::UserService.new(@requestor); end
    def comments;                    @comments ||= Services::CommentService.new(@requestor); end
    def organizations;               @organizations ||= Services::OrganizationService.new(@requestor); end
    def tags;                        @tags ||= Services::TagService.new(@requestor); end
    def follows;                     @follows ||= Services::FollowService.new(@requestor); end
    def followers;                   @followers ||= Services::FollowerService.new(@requestor); end
    def reading_list;                @reading_list ||= Services::ReadingListService.new(@requestor); end
    def podcast_episodes;            @podcast_episodes ||= Services::PodcastEpisodeService.new(@requestor); end
    def videos;                      @videos ||= Services::VideoService.new(@requestor); end
    def profile_images;              @profile_images ||= Services::ProfileImageService.new(@requestor); end
    def billboards;                  @billboards ||= Services::BillboardService.new(@requestor); end
    def pages;                       @pages ||= Services::PageService.new(@requestor); end
    def segments;                    @segments ||= Services::SegmentService.new(@requestor); end
    def reactions;                   @reactions ||= Services::ReactionService.new(@requestor); end
    def recommended_articles_lists;  @recommended_articles_lists ||= Services::RecommendedArticlesListService.new(@requestor); end
    def agent_sessions;              @agent_sessions ||= Services::AgentSessionService.new(@requestor); end
    def surveys;                     @surveys ||= Services::SurveyService.new(@requestor); end
    def analytics;                   @analytics ||= Services::AnalyticsService.new(@requestor); end
    def health_checks;               @health_checks ||= Services::HealthCheckService.new(@requestor); end
    def admin_users;                 @admin_users ||= Services::AdminUserService.new(@requestor); end
  end
end
