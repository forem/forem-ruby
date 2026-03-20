# forem-ruby API Client Gem — Design Spec

## Overview

A Ruby API client gem for the Forem platform, modeled after stripe-ruby's design patterns. Hand-crafted resource classes, mixin-based CRUD operations, both global and client-instance configuration, zero external dependencies.

## Decisions

- **Name**: `forem-ruby` (repo at `~/forem-ruby`)
- **API version**: V1 only (`Accept: application/vnd.forem.api-v1+json`)
- **Configuration**: Both global (`Forem.api_key`) and client-instance (`Forem::Client.new`)
- **Ruby version**: 3.1+
- **Resources**: Hand-crafted (not auto-generated)
- **Scope**: Full coverage (~45 endpoints)
- **Architecture**: Stripe-faithful — mixin-based CRUD, dynamic object attributes, rich error hierarchy

## Core Object Model

```
Forem::ForemObject (base)
├── Dynamic attribute access (dot + bracket notation)
├── Tracks original values, unsaved changes
├── Serialization for update params
├── Nested object conversion
│
└── Forem::APIResource
    ├── resource_url / self.resource_url
    ├── retrieve(id, opts)
    ├── refresh
    │
    ├── Article (Create, List, Retrieve, Update + unpublish, me, search)
    ├── User (Retrieve, List + me, search, suspend, role management)
    ├── Comment (List, Retrieve)
    ├── Organization (Create, List, Retrieve, Update, Delete + nested users/articles)
    ├── Tag (List)
    ├── Follow (List, Create)
    ├── Follower (List)
    ├── ReadingList (List)
    ├── PodcastEpisode (List)
    ├── Video (List)
    ├── ProfileImage (Retrieve)
    ├── Billboard (Create, List, Retrieve, Update + unpublish)
    ├── Page (Create, List, Retrieve, Update, Delete)
    ├── Segment (Create, List, Retrieve, Delete + users, add_users, remove_users)
    ├── Reaction (Create + toggle)
    ├── RecommendedArticlesList (Create, List, Retrieve, Update)
    ├── AgentSession (Create, List, Retrieve + presign, raw_url)
    ├── Survey (List, Retrieve + responses)
    ├── Analytics (totals, historical, past_day, referrers)
    └── HealthCheck (app, database, cache)

Forem::ListObject
├── data, current_page, per_page, filters
├── has_more? (inferred: data.length == per_page)
├── each (current page) / auto_paging_each (all pages)
└── next_page / previous_page
```

## CRUD Mixins (APIOperations)

```
Forem::APIOperations::
├── Create    — self.create(params, opts)     → POST
├── List      — self.list(params, opts)       → GET, returns ListObject
├── Retrieve  — self.retrieve(id, opts)       → GET
├── Update    — self.update(id, params, opts) → PUT
├── Delete    — self.delete(id, opts)         → DELETE
├── Request   — core HTTP execution (included in APIResource)
└── Save      — save instance method (calls Update with unsaved changes)
```

Custom actions (unpublish, me, suspend, etc.) are regular methods on the resource class — no extra abstraction.

Example resource:

```ruby
module Forem
  class Article < APIResource
    extend Forem::APIOperations::Create
    extend Forem::APIOperations::List
    extend Forem::APIOperations::Retrieve
    extend Forem::APIOperations::Update
    include Forem::APIOperations::Save

    OBJECT_NAME = "article"
    RESOURCE_PATH = "/api/articles"

    def unpublish(opts = {})
      request(:put, "#{resource_url}/unpublish", {}, opts)
    end

    def self.me(params = {}, opts = {})
      request(:get, "/api/articles/me", params, opts)
    end
  end
end
```

## Configuration & Client Architecture

```ruby
# Global configuration
Forem.api_key = "your-api-key"
Forem.api_base = "https://dev.to"  # default
Forem.open_timeout = 30
Forem.read_timeout = 80
Forem.max_network_retries = 1

article = Forem::Article.retrieve(123)

# Client-instance configuration
client = Forem::Client.new("your-api-key", api_base: "https://my-forem.com")
article = client.articles.retrieve(123)

# Per-request overrides
Forem::Article.list({}, { api_key: "different-key" })
```

Configuration object (`Forem::Configuration`):
- `api_key` — required for authenticated endpoints
- `api_base` — defaults to `https://dev.to`
- `api_version` — sends V1 Accept header
- `open_timeout` (30s), `read_timeout` (80s)
- `max_network_retries` (1)
- `log_level`, `logger`

Client resource accessors (`client.articles`, `client.users`, etc.) return proxy objects binding the client's config to each API call.

## HTTP Client & Request Handling

**`Forem::APIRequestor`** — central request executor:
- `Net::HTTP` from stdlib (zero dependencies)
- Headers: `api-key`, `Accept: application/vnd.forem.api-v1+json`, `Content-Type: application/json`, `User-Agent: forem-ruby/<version>`
- JSON encode bodies, JSON parse responses
- Returns `Forem::ForemResponse` (status, headers, body)

**Retry logic**:
- Retries on: network timeouts, connection refused/reset, 5xx
- No retry on 4xx
- Exponential backoff: `0.5 * (2 ^ retry_count)` with jitter
- Configurable via `max_network_retries`

**`Forem::ConnectionManager`**:
- Persistent connections with keep-alive
- Per-thread connection pooling
- SSL/TLS verification enabled

**Request flow**:
```
Resource method → APIOperations mixin → APIRequestor → ConnectionManager → Net::HTTP
Response parsed → ForemObject constructed (or error raised)
```

## Error Handling

```
Forem::ForemError (base)
├── message, http_status, http_body, http_headers, code
│
├── AuthenticationError     # 401
├── AuthorizationError      # 403
├── NotFoundError           # 404
├── InvalidRequestError     # 422
├── RateLimitError          # 429
├── APIError                # 5xx / unknown
└── APIConnectionError      # network failures
```

Forem returns `{ "error": "message", "status": 422 }`. Mapped 1:1 from HTTP status codes.

## Pagination

Offset-based (`page`/`per_page`), not cursor-based.

```ruby
articles = Forem::Article.list(per_page: 30, page: 1)
articles.data          # => [#<Forem::Article>, ...]
articles.current_page  # => 1
articles.has_more?     # => true (data.length == per_page)

# Auto-pagination
Forem::Article.list(per_page: 100).auto_paging_each do |article|
  puts article.title
end
```

`has_more?` inferred: if `data.length == per_page`, likely more pages exist. Stops when a page returns fewer items or is empty.

## File Structure

```
forem-ruby/
├── forem-ruby.gemspec
├── Gemfile
├── Rakefile
├── LICENSE
├── README.md
├── lib/
│   ├── forem.rb
│   └── forem/
│       ├── version.rb
│       ├── configuration.rb
│       ├── client.rb
│       ├── forem_object.rb
│       ├── api_resource.rb
│       ├── list_object.rb
│       ├── forem_response.rb
│       ├── api_requestor.rb
│       ├── connection_manager.rb
│       ├── errors.rb
│       ├── util.rb
│       ├── api_operations/
│       │   ├── create.rb
│       │   ├── delete.rb
│       │   ├── list.rb
│       │   ├── retrieve.rb
│       │   ├── update.rb
│       │   ├── save.rb
│       │   └── request.rb
│       └── resources/
│           ├── article.rb
│           ├── user.rb
│           ├── comment.rb
│           ├── organization.rb
│           ├── tag.rb
│           ├── follow.rb
│           ├── follower.rb
│           ├── reading_list.rb
│           ├── podcast_episode.rb
│           ├── video.rb
│           ├── profile_image.rb
│           ├── billboard.rb
│           ├── page.rb
│           ├── segment.rb
│           ├── reaction.rb
│           ├── recommended_articles_list.rb
│           ├── agent_session.rb
│           ├── survey.rb
│           ├── analytics.rb
│           └── health_check.rb
└── test/
    ├── test_helper.rb
    ├── forem_test.rb
    └── forem/
        ├── forem_object_test.rb
        ├── api_resource_test.rb
        ├── list_object_test.rb
        ├── api_requestor_test.rb
        ├── errors_test.rb
        ├── client_test.rb
        └── resources/
            └── (one test per resource)
```

## Testing

- **Minitest** (zero-dependency, matches stripe-ruby)
- Stub `Net::HTTP` at connection level
- Test helper with `stub_request` for capturing/verifying requests
- Per-resource tests: correct HTTP method, path, params, response parsing
- Error mapping tests, pagination tests

## Dependencies

- Runtime: none (Ruby stdlib only)
- Development: minitest, rake
