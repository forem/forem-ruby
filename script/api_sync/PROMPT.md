# Forem API -> `forem-ruby` Autonomous Sync Instructions

You are maintaining `forem/forem-ruby` so it stays **100% in sync** with all HTTP API changes in `forem/forem`.

## Inputs available in this workspace

1. Current working directory: `forem/forem-ruby` repository root.
2. Upstream checkout: `../forem` (`forem/forem` checked out at the target commit).
3. Audit report:
   - `tmp/api_sync_report.md` (human-readable summary, route drift, upstream commits, and unified diffs)
   - `tmp/api_sync_report.json` (structured report)
4. Sync manifest: `.forem-api-sync.json` (tracks `forem_sha`, every Forem API route mapping, and watched API file digests).

## Your Mission

Inspect `tmp/api_sync_report.md` and the full upstream source files in `../forem` (routes, controllers, concerns, Jbuilder views, serializers, and request specs under `../forem/spec/requests/api/`) for every changed or unmapped endpoint.

Then bring `forem-ruby` to **100% parity** with `../forem` at its current `HEAD`:

### 1. Classify every upstream change carefully
- **New routes / endpoints**: Implement the corresponding resource method(s), service method(s), `Forem::Client` accessor (if a new resource), `lib/forem.rb` require, YARD documentation, Minitest tests, `README.md` resource table update, and `.forem-api-sync.json` entry.
- **Changed request params / envelopes / HTTP verbs / headers / query params**: Update the SDK methods, parameter handling (e.g. flat vs enveloped params, multipart uploads, custom headers), YARD docs, and tests to match Forem's exact controller behavior.
- **Changed response shapes / pagination / error codes**: Update response parsing/construction (e.g. `ListObject`, `ForemObject`, unwrapped envelope keys, empty/204 responses) and tests.
- **Removed or renamed routes**: Update or deprecate the SDK methods cleanly and update `.forem-api-sync.json` and tests.
- **Previously excluded route now implemented in Forem**: Implement it in the SDK and switch its `.forem-api-sync.json` status from `excluded` to `implemented`.
- **Internal-only Forem refactors** (e.g. Rust `ForemNative` serialization speedups, SQL query optimizations, caching/surrogate-key tweaks, RuboCop/audit logging that do NOT change HTTP routes, request params, headers, status codes, or response JSON contracts): Verify from the diff and specs that the external HTTP contract is unchanged; no SDK code change is required for those, just update `.forem-api-sync.json` via `snapshot-digests --write`.
- **Non-public/non-SDK routes** (ONLY exclude with an explicit reason in `.forem-api-sync.json` if a route is strictly test-environment-only like `feature_flags`, an explicitly deprecated alias like `display_ads`, an unimplemented dangling route in Forem, or an internal non-API-key auth flow like `mobile_auth`). All real Forem API endpoints MUST be implemented.

### 2. Follow `forem-ruby` conventions strictly
- **Zero runtime dependencies**: Only Ruby standard library (`net/http`, `json`, `uri`, `cgi`, etc.). Never add runtime gems to `forem-ruby.gemspec`.
- **Ruby >= 3.1 compatibility**: Avoid syntax or stdlib features unavailable in Ruby 3.1.
- **Client-scoped architecture**: No global `Forem.api_key` or global mutable state. Every call goes through a `Forem::Client` instance -> `Services::*Service` -> `Forem::*` resource -> `APIRequestor`.
- **Resource & Service pairing**:
  - Resource in `lib/forem/resources/<name>.rb` inheriting from `Forem::APIResource` with `OBJECT_NAME` and `RESOURCE_PATH`.
  - Service in `lib/forem/services/<name>_service.rb` inheriting from `Forem::Services::BaseService` using `opts_with_requestor(opts)`.
  - Require both in `lib/forem.rb` and expose a memoized accessor on `Forem::Client` in `lib/forem/client.rb`.
  - Use `enveloped(:key, params)` (or equivalent idempotent wrapping) whenever a Forem controller uses `params.require(:key)` so both flat and wrapped call styles work.
  - Keep `README.md` Resources table and examples accurate.
- **Tests**:
  - Add thorough Minitest unit tests in `test/forem/resources/` and `test/forem/services/` using `StubRequestHelper` from `test/test_helper.rb`.
  - Update `test/forem/client_test.rb` and `test/integration_test.rb` for any new client accessors/services.
- **Do NOT bump `lib/forem/version.rb`**: Version bumps and gem releases are handled separately by maintainers.

### 3. Update `.forem-api-sync.json` and run all verification gates
1. Update the `"endpoints"` entries in `.forem-api-sync.json` for any added, changed, or removed routes.
2. Refresh `forem_sha`, `synced_at`, and `file_digests`:
   ```sh
   ruby script/api_sync/cli.rb snapshot-digests --forem-dir ../forem --write
   ```
3. Run ALL required verification checks and fix any issues until all pass with exit code 0:
   ```sh
   bundle exec rake test
   ruby script/api_sync/cli.rb verify --forem-dir ../forem
   gem build forem-ruby.gemspec && rm -f forem-ruby-*.gem
   ```
4. Leave a concise Markdown summary in `tmp/api_sync_pr_summary.md` describing:
   - Which upstream `forem/forem` commits were reviewed
   - What SDK endpoints/params/responses were added or updated (or confirming that upstream changes were internal-only with no HTTP contract changes)
   - Verification results
