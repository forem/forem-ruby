# frozen_string_literal: true

require "digest"
require "json"
require "open3"
require "time"
require_relative "route_extractor"
require_relative "sdk_introspector"

module ForemApiSync
  # Compares a checkout of `forem/forem` against `.forem-api-sync.json` and the
  # live `forem-ruby` SDK, producing both structured JSON and Markdown reports.
  class DiffEngine
    DEFAULT_WATCHED_PATHS = [
      "config/routes.rb",
      "config/routes/api.rb",
      "app/controllers/api",
      "app/controllers/concerns/api",
      "app/views/api",
      "swagger",
      "public/openapi.yml"
    ].freeze

    MAX_DIFF_BYTES_PER_FILE = 12_000
    MAX_TOTAL_DIFF_BYTES = 120_000

    def initialize(repo_root:, forem_dir:, manifest_path: nil)
      @repo_root = File.expand_path(repo_root)
      @forem_dir = File.expand_path(forem_dir)
      @manifest_path = manifest_path || File.join(@repo_root, ".forem-api-sync.json")
    end

    def load_manifest
      raise "Missing manifest: #{@manifest_path}" unless File.exist?(@manifest_path)

      JSON.parse(File.read(@manifest_path))
    end

    # Offline manifest + SDK binding validation (no forem/forem checkout needed).
    def verify_manifest_only
      manifest = load_manifest
      introspector = SdkIntrospector.new(lib_dir: File.join(@repo_root, "lib"))
      errors = validate_manifest_schema(manifest)
      endpoints = manifest["endpoints"] || {}

      endpoints.each do |route_key, entry|
        next unless entry["status"] == "implemented"

        errors.concat(introspector.validate_binding(route_key, entry["sdk"]))
      end

      {
        "ok" => errors.empty?,
        "forem_sha" => manifest["forem_sha"],
        "total_endpoints" => endpoints.size,
        "implemented_count" => endpoints.values.count { |e| e["status"] == "implemented" },
        "excluded_count" => endpoints.values.count { |e| e["status"] == "excluded" },
        "errors" => errors
      }
    end

    # Full audit comparing forem/forem against `.forem-api-sync.json` and the SDK.
    def audit(force_full_audit: false)
      manifest = load_manifest
      watched_paths = manifest["watched_paths"] || DEFAULT_WATCHED_PATHS
      last_sha = manifest["forem_sha"]
      head_sha = git_rev_parse(@forem_dir, "HEAD")

      extracted_routes = RouteExtractor.new(forem_dir: @forem_dir).extract
      extracted_by_key = extracted_routes.each_with_object({}) { |r, h| h[r.key] = r }
      manifest_endpoints = manifest["endpoints"] || {}

      unmapped_routes = []
      changed_route_targets = []
      newly_implemented_excluded = []

      extracted_routes.each do |route|
        entry = manifest_endpoints[route.key]
        if entry.nil?
          unmapped_routes << route.to_h
          next
        end

        if entry["controller"] != route.controller || entry["action"] != route.action
          changed_route_targets << {
            "key" => route.key,
            "manifest" => "#{entry["controller"]}##{entry["action"]}",
            "forem" => "#{route.controller}##{route.action}"
          }
        end

        if entry["status"] == "excluded" &&
           entry["reason"] == "unimplemented_route_in_forem" &&
           route.action_implemented
          newly_implemented_excluded << route.to_h
        end
      end

      removed_routes = (manifest_endpoints.keys - extracted_by_key.keys).sort.map do |key|
        { "key" => key, "manifest_entry" => manifest_endpoints[key] }
      end

      introspector = SdkIntrospector.new(lib_dir: File.join(@repo_root, "lib"))
      broken_sdk_mappings = []
      manifest_endpoints.each do |route_key, entry|
        next unless entry["status"] == "implemented"

        broken_sdk_mappings.concat(introspector.validate_binding(route_key, entry["sdk"]))
      end

      current_digests = compute_file_digests(watched_paths)
      previous_digests = manifest["file_digests"] || {}
      digest_changes = diff_digests(previous_digests, current_digests)

      commits = []
      file_diffs = {}
      changed_files = (digest_changes["added"] + digest_changes["modified"] + digest_changes["removed"]).uniq.sort
      changed_git_paths = changed_files.map { |f| f.split("#", 2).first }.uniq
      history_available = last_sha && head_sha && git_ancestor_or_present?(@forem_dir, last_sha)
      if history_available && last_sha != head_sha && changed_git_paths.any?
        commits = collect_api_commits(last_sha, head_sha, changed_git_paths)
        file_diffs = collect_file_diffs(last_sha, head_sha, changed_git_paths)
      elsif !history_available && changed_files.any?
        commits = [{ "sha" => head_sha, "subject" => "(shallow clone or unrecorded base SHA; using file digest diff)" }]
      end

      has_route_drift = [
        unmapped_routes,
        removed_routes,
        changed_route_targets,
        newly_implemented_excluded,
        broken_sdk_mappings
      ].any?(&:any?)

      has_upstream_api_changes = changed_files.any? || commits.any?
      needs_sync = force_full_audit || has_route_drift || has_upstream_api_changes

      {
        "needs_sync" => needs_sync,
        "has_route_drift" => has_route_drift,
        "has_upstream_api_changes" => has_upstream_api_changes,
        "force_full_audit" => force_full_audit,
        "forem_repo" => manifest["forem_repo"] || "forem/forem",
        "last_synced_sha" => last_sha,
        "head_sha" => head_sha,
        "summary" => {
          "extracted_routes" => extracted_routes.size,
          "manifest_endpoints" => manifest_endpoints.size,
          "implemented_endpoints" => manifest_endpoints.values.count { |e| e["status"] == "implemented" },
          "excluded_endpoints" => manifest_endpoints.values.count { |e| e["status"] == "excluded" },
          "unmapped_routes" => unmapped_routes.size,
          "removed_routes" => removed_routes.size,
          "changed_route_targets" => changed_route_targets.size,
          "newly_implemented_excluded" => newly_implemented_excluded.size,
          "broken_sdk_mappings" => broken_sdk_mappings.size,
          "upstream_api_commits" => commits.size,
          "changed_api_files" => (digest_changes["added"] + digest_changes["modified"] + digest_changes["removed"]).uniq.size
        },
        "unmapped_routes" => unmapped_routes,
        "removed_routes" => removed_routes,
        "changed_route_targets" => changed_route_targets,
        "newly_implemented_excluded" => newly_implemented_excluded,
        "broken_sdk_mappings" => broken_sdk_mappings,
        "digest_changes" => digest_changes,
        "upstream_commits" => commits,
        "file_diffs" => file_diffs
      }
    end

    # Strict verification: every Forem route mapped/excluded, all SDK bindings
    # valid, and (unless allow_sha_mismatch) manifest SHA & file digests match.
    def verify(allow_sha_mismatch: false)
      report = audit
      errors = []

      report["unmapped_routes"].each do |r|
        errors << "Unmapped Forem route: #{r["key"]} (#{r["controller"]}##{r["action"]})"
      end
      report["removed_routes"].each do |r|
        errors << "Stale manifest route no longer in Forem: #{r["key"]}"
      end
      report["changed_route_targets"].each do |r|
        errors << "Changed target for #{r["key"]}: manifest=#{r["manifest"]}, forem=#{r["forem"]}"
      end
      report["newly_implemented_excluded"].each do |r|
        errors << "Previously unimplemented route is now implemented in Forem: #{r["key"]}"
      end
      errors.concat(report["broken_sdk_mappings"])

      unless allow_sha_mismatch
        if report["head_sha"] && report["last_synced_sha"] != report["head_sha"]
          errors << "Manifest forem_sha (#{report["last_synced_sha"]}) does not match Forem HEAD (#{report["head_sha"]})"
        end
        dc = report["digest_changes"]
        if dc.values.any?(&:any?)
          changed_count = dc.values.flatten.size
          errors << "Manifest file_digests out of date (#{changed_count} changed API files)"
        end
      end

      {
        "ok" => errors.empty?,
        "errors" => errors,
        "summary" => report["summary"],
        "last_synced_sha" => report["last_synced_sha"],
        "head_sha" => report["head_sha"]
      }
    end

    # Updates `forem_sha`, `synced_at`, and `file_digests` in `.forem-api-sync.json`.
    def snapshot_digests!(write: false)
      manifest = load_manifest
      watched_paths = manifest["watched_paths"] || DEFAULT_WATCHED_PATHS
      head_sha = git_rev_parse(@forem_dir, "HEAD")
      digests = compute_file_digests(watched_paths)

      manifest["forem_sha"] = head_sha if head_sha
      manifest["synced_at"] = Time.now.utc.iso8601
      manifest["file_digests"] = digests

      if write
        File.write(@manifest_path, "#{JSON.pretty_generate(manifest)}\n")
      end
      manifest
    end

    def render_markdown(report)
      lines = []
      s = report["summary"]
      repo = report["forem_repo"]
      last_sha = report["last_synced_sha"] || "(none)"
      head_sha = report["head_sha"] || "(unknown)"

      lines << "# Forem API Sync Audit Report"
      lines << ""
      lines << "- **Upstream repo:** `#{repo}`"
      lines << "- **Last synced SHA:** `#{last_sha}`"
      lines << "- **Current upstream HEAD:** `#{head_sha}`"
      lines << "- **Sync required:** `#{report["needs_sync"]}`"
      lines << ""
      lines << "## Summary"
      lines << ""
      lines << "| Metric | Count |"
      lines << "|---|---:|"
      lines << "| Forem API routes extracted | #{s["extracted_routes"]} |"
      lines << "| Manifest implemented endpoints | #{s["implemented_endpoints"]} |"
      lines << "| Manifest excluded endpoints | #{s["excluded_endpoints"]} |"
      lines << "| Unmapped (new) routes | #{s["unmapped_routes"]} |"
      lines << "| Removed (stale) routes | #{s["removed_routes"]} |"
      lines << "| Changed route targets | #{s["changed_route_targets"]} |"
      lines << "| Newly implemented excluded routes | #{s["newly_implemented_excluded"]} |"
      lines << "| Broken SDK bindings | #{s["broken_sdk_mappings"]} |"
      lines << "| Upstream API commits since last sync | #{s["upstream_api_commits"]} |"
      lines << "| Changed watched API files | #{s["changed_api_files"]} |"
      lines << ""

      if report["unmapped_routes"].any?
        lines << "## Unmapped (New) Forem Routes"
        lines << ""
        report["unmapped_routes"].each do |r|
          flags = []
          flags << "env=#{r["env_constraint"]}" if r["env_constraint"]
          flags << "unimplemented_in_forem" unless r["action_implemented"]
          suffix = flags.empty? ? "" : " (#{flags.join(", ")})"
          lines << "- `#{r["key"]}` -> `#{r["controller"]}##{r["action"]}`#{suffix}"
        end
        lines << ""
      end

      if report["removed_routes"].any?
        lines << "## Removed (Stale) Routes"
        lines << ""
        report["removed_routes"].each do |r|
          lines << "- `#{r["key"]}`"
        end
        lines << ""
      end

      if report["changed_route_targets"].any?
        lines << "## Changed Route Targets"
        lines << ""
        report["changed_route_targets"].each do |r|
          lines << "- `#{r["key"]}`: `#{r["manifest"]}` -> `#{r["forem"]}`"
        end
        lines << ""
      end

      if report["newly_implemented_excluded"].any?
        lines << "## Previously Unimplemented Routes Now Active in Forem"
        lines << ""
        report["newly_implemented_excluded"].each do |r|
          lines << "- `#{r["key"]}` -> `#{r["controller"]}##{r["action"]}`"
        end
        lines << ""
      end

      if report["broken_sdk_mappings"].any?
        lines << "## Broken SDK Bindings"
        lines << ""
        report["broken_sdk_mappings"].each { |e| lines << "- #{e}" }
        lines << ""
      end

      if report["upstream_commits"].any?
        lines << "## Upstream `#{repo}` API Commits"
        lines << ""
        report["upstream_commits"].each do |c|
          short = c["sha"] ? c["sha"][0, 10] : "unknown"
          date = c["date"] ? " (#{c["date"]})" : ""
          lines << "- [`#{short}`](https://github.com/#{repo}/commit/#{c["sha"]}) #{c["subject"]}#{date}"
        end
        lines << ""
      end

      dc = report["digest_changes"]
      if dc.values.any?(&:any?)
        lines << "## Changed API Files"
        lines << ""
        %w[added modified removed].each do |kind|
          next if dc[kind].empty?

          lines << "### #{kind.capitalize}"
          dc[kind].each { |f| lines << "- `#{f}`" }
          lines << ""
        end
      end

      if report["file_diffs"].any?
        lines << "## Unified Diffs (API Surface)"
        lines << ""
        report["file_diffs"].each do |file, diff_text|
          lines << "### `#{file}`"
          lines << "```diff"
          lines << diff_text.chomp
          lines << "```"
          lines << ""
        end
      end

      lines.join("\n")
    end

    private

    def validate_manifest_schema(manifest)
      errors = []
      errors << "Manifest must be a JSON object" unless manifest.is_a?(Hash)
      return errors unless errors.empty?

      errors << "Manifest missing `schema_version`" unless manifest["schema_version"]
      errors << "Manifest missing `endpoints` hash" unless manifest["endpoints"].is_a?(Hash)

      (manifest["endpoints"] || {}).each do |key, entry|
        unless entry.is_a?(Hash)
          errors << "#{key}: endpoint entry must be an object"
          next
        end
        status = entry["status"]
        unless %w[implemented excluded].include?(status)
          errors << "#{key}: invalid status `#{status}` (must be `implemented` or `excluded`)"
        end
        if status == "excluded" && entry["reason"].to_s.strip.empty?
          errors << "#{key}: excluded endpoint must specify a non-empty `reason`"
        end
      end

      errors
    end

    def compute_file_digests(watched_paths)
      extractor = RouteExtractor.new(forem_dir: @forem_dir)
      digests = {}

      watched_paths.each do |rel|
        full = File.join(@forem_dir, rel)
        if rel == "config/routes.rb" && File.file?(full)
          # Hash only the `namespace :api` block so unrelated web route edits
          # in config/routes.rb do not trigger false-positive API sync runs.
          api_block = extractor.extract_api_namespace_block(File.read(full))
          digests["config/routes.rb#namespace:api"] = Digest::SHA256.hexdigest(api_block)
        elsif File.directory?(full)
          Dir.glob(File.join(full, "**", "*")).sort.each do |path|
            next unless File.file?(path)

            file_rel = path.delete_prefix("#{@forem_dir}/")
            digests[file_rel] = Digest::SHA256.file(path).hexdigest
          end
        elsif File.file?(full)
          digests[rel] = Digest::SHA256.file(full).hexdigest
        end
      end

      digests.sort.to_h
    end

    def diff_digests(previous, current)
      prev_keys = previous.keys
      curr_keys = current.keys
      {
        "added" => (curr_keys - prev_keys).sort,
        "removed" => (prev_keys - curr_keys).sort,
        "modified" => (prev_keys & curr_keys).select { |k| previous[k] != current[k] }.sort
      }
    end

    def git_rev_parse(dir, ref)
      out, _err, status = Open3.capture3("git", "-C", dir, "rev-parse", "--verify", "#{ref}^{commit}")
      status.success? ? out.strip : nil
    rescue Errno::ENOENT
      nil
    end

    def git_ancestor_or_present?(dir, sha)
      return false if sha.nil? || sha.empty?

      _out, _err, status = Open3.capture3("git", "-C", dir, "cat-file", "-e", "#{sha}^{commit}")
      status.success?
    rescue Errno::ENOENT
      false
    end

    def collect_api_commits(base_sha, head_sha, watched_paths)
      existing_paths = watched_paths.select { |p| File.exist?(File.join(@forem_dir, p)) }
      return [] if existing_paths.empty?

      cmd = [
        "git", "-C", @forem_dir, "log",
        "--no-merges",
        "--format=%H%x1f%cs%x1f%s",
        "#{base_sha}..#{head_sha}",
        "--", *existing_paths
      ]
      out, status = Open3.capture2(*cmd)
      return [] unless status.success?

      out.lines.filter_map do |line|
        sha, date, subject = line.chomp.split("\x1f", 3)
        next unless sha && !sha.empty?

        { "sha" => sha, "date" => date, "subject" => subject }
      end
    end

    def collect_file_diffs(base_sha, head_sha, files)
      diffs = {}
      total_bytes = 0

      files.each do |rel|
        break if total_bytes >= MAX_TOTAL_DIFF_BYTES

        out, status = Open3.capture2(
          "git", "-C", @forem_dir, "diff", "--unified=3",
          "#{base_sha}..#{head_sha}", "--", rel
        )
        next unless status.success? && !out.empty?

        if out.bytesize > MAX_DIFF_BYTES_PER_FILE
          out = "#{out.byteslice(0, MAX_DIFF_BYTES_PER_FILE)}\n... [truncated; inspect full file in forem checkout: #{rel}]"
        end
        diffs[rel] = out
        total_bytes += out.bytesize
      end

      diffs
    end
  end
end
