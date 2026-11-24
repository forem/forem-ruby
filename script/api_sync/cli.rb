#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "fileutils"
require_relative "diff_engine"

module ForemApiSync
  class CLI
    REPO_ROOT = File.expand_path("../..", __dir__)

    def self.run(argv)
      new.run(argv)
    end

    def run(argv)
      command = argv.shift
      case command
      when "audit"
        run_audit(argv)
      when "verify"
        run_verify(argv)
      when "verify-manifest"
        run_verify_manifest(argv)
      when "snapshot-digests"
        run_snapshot_digests(argv)
      when "routes"
        run_routes(argv)
      else
        warn usage
        1
      end
    rescue StandardError => e
      warn "ERROR: #{e.message}"
      warn e.backtrace.first(5).join("\n") if ENV["DEBUG"]
      1
    end

    private

    def run_audit(argv)
      opts = { force_full_audit: false }
      OptionParser.new do |o|
        o.on("--forem-dir PATH", "Path to forem/forem checkout") { |v| opts[:forem_dir] = v }
        o.on("--manifest PATH", "Path to .forem-api-sync.json") { |v| opts[:manifest] = v }
        o.on("--json-out PATH", "Write JSON audit report to PATH") { |v| opts[:json_out] = v }
        o.on("--markdown-out PATH", "Write Markdown audit report to PATH") { |v| opts[:markdown_out] = v }
        o.on("--force-full-audit", "Force needs_sync=true even when no diffs are detected") { opts[:force_full_audit] = true }
      end.parse!(argv)

      raise "--forem-dir is required" unless opts[:forem_dir]

      engine = DiffEngine.new(
        repo_root: REPO_ROOT,
        forem_dir: opts[:forem_dir],
        manifest_path: opts[:manifest]
      )
      report = engine.audit(force_full_audit: opts[:force_full_audit])
      markdown = engine.render_markdown(report)

      write_output(opts[:json_out], "#{JSON.pretty_generate(report)}\n") if opts[:json_out]
      write_output(opts[:markdown_out], "#{markdown}\n") if opts[:markdown_out]
      puts markdown unless opts[:markdown_out]

      report["needs_sync"] ? 2 : 0
    end

    def run_verify(argv)
      opts = { allow_sha_mismatch: false }
      OptionParser.new do |o|
        o.on("--forem-dir PATH", "Path to forem/forem checkout") { |v| opts[:forem_dir] = v }
        o.on("--manifest PATH", "Path to .forem-api-sync.json") { |v| opts[:manifest] = v }
        o.on("--allow-sha-mismatch", "Allow manifest forem_sha/file_digests to differ from forem HEAD") do
          opts[:allow_sha_mismatch] = true
        end
      end.parse!(argv)

      raise "--forem-dir is required" unless opts[:forem_dir]

      engine = DiffEngine.new(
        repo_root: REPO_ROOT,
        forem_dir: opts[:forem_dir],
        manifest_path: opts[:manifest]
      )
      result = engine.verify(allow_sha_mismatch: opts[:allow_sha_mismatch])

      if result["ok"]
        s = result["summary"]
        puts "OK: #{s["extracted_routes"]} Forem API routes verified (#{s["implemented_endpoints"]} implemented, #{s["excluded_endpoints"]} excluded) at #{result["last_synced_sha"]}"
        0
      else
        warn "FAILED: Forem API sync verification found #{result["errors"].size} issue(s):"
        result["errors"].each { |err| warn "  - #{err}" }
        1
      end
    end

    def run_verify_manifest(argv)
      opts = {}
      OptionParser.new do |o|
        o.on("--manifest PATH", "Path to .forem-api-sync.json") { |v| opts[:manifest] = v }
      end.parse!(argv)

      engine = DiffEngine.new(
        repo_root: REPO_ROOT,
        forem_dir: REPO_ROOT,
        manifest_path: opts[:manifest]
      )
      result = engine.verify_manifest_only

      if result["ok"]
        puts "OK: .forem-api-sync.json valid (#{result["implemented_count"]} implemented, #{result["excluded_count"]} excluded, forem_sha=#{result["forem_sha"]})"
        0
      else
        warn "FAILED: .forem-api-sync.json validation found #{result["errors"].size} issue(s):"
        result["errors"].each { |err| warn "  - #{err}" }
        1
      end
    end

    def run_snapshot_digests(argv)
      opts = { write: false }
      OptionParser.new do |o|
        o.on("--forem-dir PATH", "Path to forem/forem checkout") { |v| opts[:forem_dir] = v }
        o.on("--manifest PATH", "Path to .forem-api-sync.json") { |v| opts[:manifest] = v }
        o.on("--write", "Write updated forem_sha, synced_at, and file_digests back to manifest") { opts[:write] = true }
      end.parse!(argv)

      raise "--forem-dir is required" unless opts[:forem_dir]

      engine = DiffEngine.new(
        repo_root: REPO_ROOT,
        forem_dir: opts[:forem_dir],
        manifest_path: opts[:manifest]
      )
      manifest = engine.snapshot_digests!(write: opts[:write])
      puts "Snapshotted #{manifest["file_digests"].size} API files at #{manifest["forem_sha"]} (write=#{opts[:write]})"
      0
    end

    def run_routes(argv)
      opts = {}
      OptionParser.new do |o|
        o.on("--forem-dir PATH", "Path to forem/forem checkout") { |v| opts[:forem_dir] = v }
      end.parse!(argv)

      raise "--forem-dir is required" unless opts[:forem_dir]

      routes = RouteExtractor.new(forem_dir: opts[:forem_dir]).extract
      puts JSON.pretty_generate(routes.map(&:to_h))
      0
    end

    def write_output(path, content)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
    end

    def usage
      <<~USAGE
        Usage: ruby script/api_sync/cli.rb <command> [options]

        Commands:
          audit --forem-dir PATH [--json-out PATH] [--markdown-out PATH] [--force-full-audit]
            Audits forem/forem routes, SDK bindings, git commits, and API file digests.
            Exits 0 if 100% in sync, 2 if sync is required, 1 on error.

          verify --forem-dir PATH [--allow-sha-mismatch]
            Strictly verifies 100% route parity, valid SDK bindings, and manifest freshness.

          verify-manifest
            Offline check of .forem-api-sync.json schema and live SDK bindings (used in CI).

          snapshot-digests --forem-dir PATH [--write]
            Refreshes forem_sha, synced_at, and file_digests in .forem-api-sync.json.

          routes --forem-dir PATH
            Prints extracted Forem API routes as JSON.
      USAGE
    end
  end
end

exit ForemApiSync::CLI.run(ARGV) if $PROGRAM_NAME == __FILE__
