require "test_helper"
require "tmpdir"
require "fileutils"
require "json"
require File.expand_path("../../script/api_sync/diff_engine", __dir__)

class ForemApiSyncTest < Minitest::Test
  REPO_ROOT = File.expand_path("../..", __dir__)

  def test_repo_manifest_is_valid_against_live_sdk
    engine = ForemApiSync::DiffEngine.new(repo_root: REPO_ROOT, forem_dir: REPO_ROOT)
    result = engine.verify_manifest_only

    assert result["ok"], "Expected .forem-api-sync.json to be valid, got errors: #{result["errors"].inspect}"
    assert_operator result["implemented_count"], :>=, 150
    assert_operator result["excluded_count"], :>=, 1
  end

  def test_route_extractor_handles_dsl_concerns_and_deduplication
    with_fake_forem do |forem_dir|
      routes = ForemApiSync::RouteExtractor.new(forem_dir: forem_dir).extract
      by_key = routes.each_with_object({}) { |r, h| h[r.key] = r }

      # Shared route drawn in both v1 and v0 resolves to v1 canonically
      assert_equal "v1", by_key["GET /api/tags"].api_version
      assert_equal "api/v1/tags", by_key["GET /api/tags"].controller
      assert_equal true, by_key["GET /api/tags"].action_implemented

      # V0-only route is preserved
      assert_equal "v0", by_key["GET /api/events"].api_version
      assert_equal "api/v0/events", by_key["GET /api/events"].controller

      # Nested resource with explicit `to:` target
      assert_equal "api/v1/trends", by_key["GET /api/trends/:trend_id_or_slug/articles"].controller
      assert_equal "articles", by_key["GET /api/trends/:trend_id_or_slug/articles"].action
      assert_equal true, by_key["GET /api/trends/:trend_id_or_slug/articles"].action_implemented

      # Constrained role segment expands into concrete routes
      assert by_key.key?("PUT /api/users/:id/trusted")
      assert by_key.key?("PUT /api/users/:id/base_subscriber")
      assert by_key.key?("DELETE /api/users/:id/base_subscriber")

      # RailsEnvConstraint recorded
      assert_equal "test", by_key["GET /api/feature_flags"].env_constraint

      # Unimplemented action flagged as action_implemented: false
      assert_equal false, by_key["GET /api/followers/organizations"].action_implemented

      # Non-API web routes outside `namespace :api` are excluded
      refute by_key.key?("GET /dashboard")
    end
  end

  def test_sdk_introspector_catches_invalid_bindings
    introspector = ForemApiSync::SdkIntrospector.new(lib_dir: File.join(REPO_ROOT, "lib"))

    assert_empty introspector.validate_binding(
      "GET /api/articles",
      { "client_accessor" => "articles", "service_method" => "list", "resource" => "Article", "resource_class_method" => "list" }
    )

    errors = introspector.validate_binding(
      "GET /api/ghosts",
      { "client_accessor" => "nonexistent", "service_method" => "list", "resource" => "NoSuchResource", "resource_class_method" => "list" }
    )
    assert_equal 2, errors.length
  end

  def test_diff_engine_detects_new_routes_controller_edits_and_ignores_non_api_routes
    with_fake_forem do |forem_dir|
      manifest_path = File.join(forem_dir, "manifest.json")
      write_matching_manifest(forem_dir, manifest_path)

      engine = ForemApiSync::DiffEngine.new(repo_root: REPO_ROOT, forem_dir: forem_dir, manifest_path: manifest_path)
      engine.snapshot_digests!(write: true)

      # 1. Clean baseline -> zero drift
      report = engine.audit
      refute report["needs_sync"]
      assert engine.verify(allow_sha_mismatch: true)["ok"]

      # 2. Editing a non-API route outside `namespace :api` does NOT trigger false-positive sync
      routes_rb = File.join(forem_dir, "config/routes.rb")
      File.write(routes_rb, File.read(routes_rb).sub('get "/dashboard", to: "dashboards#show"', 'get "/dashboard", to: "dashboards#show"' + "\n  get \"/about\", to: \"pages#about\""))
      report_non_api = engine.audit
      refute report_non_api["needs_sync"], "Non-API edit in config/routes.rb should not trigger API sync"

      # 3. Editing an API controller (param/response change without route change) triggers sync
      tags_ctrl = File.join(forem_dir, "app/controllers/api/v1/tags_controller.rb")
      File.write(tags_ctrl, "#{File.read(tags_ctrl)}\n# new param added\n")
      report_ctrl = engine.audit
      assert report_ctrl["needs_sync"]
      assert_includes report_ctrl["digest_changes"]["modified"], "app/controllers/api/v1/tags_controller.rb"

      # 4. Adding a brand-new API route is detected as unmapped
      api_routes = File.join(forem_dir, "config/routes/api.rb")
      File.write(api_routes, "#{File.read(api_routes)}\nresources :widgets, only: [:index]\n")
      report_new_route = engine.audit
      assert report_new_route["has_route_drift"]
      assert_equal ["GET /api/widgets"], report_new_route["unmapped_routes"].map { |r| r["key"] }

      # 5. Implementing a previously unimplemented excluded route is flagged
      followers_ctrl = File.join(forem_dir, "app/controllers/api/v1/followers_controller.rb")
      File.write(followers_ctrl, "class Api::V1::FollowersController\n  def users; end\n  def organizations; end\nend\n")
      report_now_impl = engine.audit
      assert_equal ["GET /api/followers/organizations"], report_now_impl["newly_implemented_excluded"].map { |r| r["key"] }
    end
  end

  private

  def with_fake_forem
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "config/routes"))
      FileUtils.mkdir_p(File.join(dir, "app/controllers/api/v1"))
      FileUtils.mkdir_p(File.join(dir, "app/controllers/api/v0"))
      FileUtils.mkdir_p(File.join(dir, "app/controllers/concerns/api"))

      File.write(File.join(dir, "config/routes.rb"), <<~RUBY)
        Rails.application.routes.draw do
          get "/dashboard", to: "dashboards#show"

          namespace :api, defaults: { format: "json" } do
            scope module: :v1, constraints: ApiConstraints.new(version: 1, default: false) do
              scope("/users/:id") do
                constraints(role: /trusted|base_subscriber/) do
                  put "/:role", to: "user_roles#update"
                end
                constraints(role: /base_subscriber/) do
                  delete "/:role", to: "user_roles#destroy"
                end
              end
              draw :api
            end

            scope module: :v0, constraints: ApiConstraints.new(version: 0, default: true) do
              resources :events, only: [:index]
              draw :api
            end
          end
        end
      RUBY

      File.write(File.join(dir, "config/routes/api.rb"), <<~RUBY)
        resources :tags, only: [:index]
        resources :trends, only: [:index], param: :id_or_slug do
          resources :articles, only: [:index], to: "trends#articles"
        end
        namespace :followers do
          get :users
          get :organizations
        end
        constraints(RailsEnvConstraint.new(allowed_envs: %w[test])) do
          resource :feature_flags, only: [:show]
        end
      RUBY

      File.write(File.join(dir, "app/controllers/concerns/api/tags_controller.rb"), <<~RUBY)
        module Api
          module TagsController
            def index; end
          end
        end
      RUBY
      File.write(File.join(dir, "app/controllers/api/v1/tags_controller.rb"), <<~RUBY)
        module Api::V1
          class TagsController
            include Api::TagsController
          end
        end
      RUBY
      File.write(File.join(dir, "app/controllers/api/v1/trends_controller.rb"), "class Api::V1::TrendsController\n  def index; end\n  def articles; end\nend\n")
      File.write(File.join(dir, "app/controllers/api/v1/followers_controller.rb"), "class Api::V1::FollowersController\n  def users; end\nend\n")
      File.write(File.join(dir, "app/controllers/api/v1/user_roles_controller.rb"), "class Api::V1::UserRolesController\n  def update; end\n  def destroy; end\nend\n")
      File.write(File.join(dir, "app/controllers/api/v1/feature_flags_controller.rb"), "class Api::V1::FeatureFlagsController\n  def show; end\nend\n")
      File.write(File.join(dir, "app/controllers/api/v0/events_controller.rb"), "class Api::V0::EventsController\n  def index; end\nend\n")

      yield dir
    end
  end

  def write_matching_manifest(forem_dir, manifest_path)
    manifest = {
      "schema_version" => 1,
      "forem_repo" => "forem/forem",
      "forem_sha" => "deadbeef",
      "watched_paths" => ForemApiSync::DiffEngine::DEFAULT_WATCHED_PATHS,
      "endpoints" => {
        "GET /api/tags" => { "status" => "implemented", "controller" => "api/v1/tags", "action" => "index", "sdk" => { "client_accessor" => "tags", "service_method" => "list", "resource" => "Tag", "resource_class_method" => "list" } },
        "GET /api/trends" => { "status" => "implemented", "controller" => "api/v1/trends", "action" => "index", "sdk" => { "client_accessor" => "trends", "service_method" => "list", "resource" => "Trend", "resource_class_method" => "list" } },
        "GET /api/trends/:trend_id_or_slug/articles" => { "status" => "implemented", "controller" => "api/v1/trends", "action" => "articles", "sdk" => { "client_accessor" => "trends", "service_method" => "articles", "resource" => "Trend", "resource_class_method" => "articles" } },
        "GET /api/followers/users" => { "status" => "implemented", "controller" => "api/v1/followers", "action" => "users", "sdk" => { "client_accessor" => "followers", "service_method" => "list", "resource" => "Follower", "resource_class_method" => "list" } },
        "GET /api/followers/organizations" => { "status" => "excluded", "reason" => "unimplemented_route_in_forem", "controller" => "api/v1/followers", "action" => "organizations" },
        "GET /api/events" => { "status" => "implemented", "controller" => "api/v0/events", "action" => "index", "sdk" => { "client_accessor" => "events", "service_method" => "list", "resource" => "Event", "resource_class_method" => "list" } },
        "GET /api/feature_flags" => { "status" => "excluded", "reason" => "test_environment_only", "controller" => "api/v1/feature_flags", "action" => "show" },
        "PUT /api/users/:id/trusted" => { "status" => "implemented", "controller" => "api/v1/user_roles", "action" => "update", "sdk" => { "resource" => "User", "resource_instance_method" => "add_trusted" } },
        "PUT /api/users/:id/base_subscriber" => { "status" => "implemented", "controller" => "api/v1/user_roles", "action" => "update", "sdk" => { "resource" => "User", "resource_instance_method" => "add_base_subscriber" } },
        "DELETE /api/users/:id/base_subscriber" => { "status" => "implemented", "controller" => "api/v1/user_roles", "action" => "destroy", "sdk" => { "resource" => "User", "resource_instance_method" => "remove_base_subscriber" } }
      },
      "file_digests" => {}
    }
    File.write(manifest_path, JSON.pretty_generate(manifest))
  end
end
