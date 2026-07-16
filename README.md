# forem-ruby

Ruby client for the [Forem API](https://developers.forem.com/api).

> **Status: 0.1-alpha.** Pre-1.0 — expect breaking changes between minor
> versions while we iterate against the live API.

## Installation

Add to your Gemfile:

```ruby
gem "forem-ruby"
```

Or install directly:

```sh
gem install forem-ruby
```

## Quick Start

All API access goes through `Forem::Client`. Each client owns its own API
key and HTTP configuration; create one (or several) and call resources
through it.

```ruby
require "forem"

client = Forem::Client.new(ENV.fetch("FOREM_API_KEY"))

# List published articles
articles = client.articles.list(tag: "ruby", per_page: 10)
articles.each { |a| puts a.title }

# Create an article (note: the Articles endpoint takes a wrapped article: hash)
article = client.articles.create(
  article: {
    title: "Hello World",
    body_markdown: "## Hello\n\nThis is my article.",
    published: false
  }
)
puts article.id

# Retrieve a single article
article = client.articles.retrieve(12345)
puts article.title
```

You can create multiple clients pointing to different Forem instances:

```ruby
devto  = Forem::Client.new("devto_key")
custom = Forem::Client.new("custom_key", api_base: "https://my.forem.instance")
```

There is no global `Forem.api_key` or `Forem.configure` — every call must
go through a client. This keeps multi-tenant code unambiguous and avoids
silent fallbacks to an unauthenticated default.

## Resources

| Client accessor | Resource class | Available operations |
|---|---|---|
| `client.articles` | `Forem::Article` | `list`, `create`, `retrieve`, `update`, `me`, `me_published`, `me_unpublished`, `me_all`, `latest`, `search`, `retrieve_by_path` |
| `client.users` | `Forem::User` | `retrieve`, `me`, `search` (by `email:` exact-match) |
| `client.comments` | `Forem::Comment` | `list`, `retrieve` |
| `client.organizations` | `Forem::Organization` | `list`, `create`, `retrieve`, `update`, `delete` |
| `client.tags` | `Forem::Tag` | `list` |
| `client.follows` | `Forem::Follow` | `list` (followed tags), `create` (follow users/orgs) |
| `client.followers` | `Forem::Follower` | `list` |
| `client.reading_list` | `Forem::ReadingList` | `list` |
| `client.podcast_episodes` | `Forem::PodcastEpisode` | `list` |
| `client.videos` | `Forem::Video` | `list` |
| `client.profile_images` | `Forem::ProfileImage` | `retrieve` |
| `client.billboards` | `Forem::Billboard` | `list`, `create`, `retrieve`, `update` |
| `client.pages` | `Forem::Page` | `list`, `create`, `retrieve`, `update`, `delete` |
| `client.segments` | `Forem::Segment` | `list`, `create`, `retrieve`, `delete` |
| `client.reactions` | `Forem::Reaction` | `create`, `toggle` (admin only) |
| `client.recommended_articles_lists` | `Forem::RecommendedArticlesList` | `list`, `create`, `retrieve`, `update` |
| `client.agent_sessions` | `Forem::AgentSession` | `list`, `create`, `retrieve`, `presign` |
| `client.surveys` | `Forem::Survey` | `list`, `retrieve` (`#poll_votes`, `#poll_text_responses` on instance) |
| `client.analytics` | `Forem::Analytics` | `totals`, `historical`, `past_day`, `referrers` |
| `client.health_checks` | `Forem::HealthCheck` | `app`, `database`, `cache` (production requires `token:`) |
| `client.admin_users` | `Forem::AdminUser` | `create`, `link_identity`, `bulk_link_identities`, `identities`, `unlink_identity`, `update_notification_settings` |

### Instance methods on retrieved objects

Returned objects retain a reference to the client that produced them, so
follow-up calls (e.g. `article.save`) work without re-passing credentials.

```ruby
# Article
article = client.articles.retrieve(12345)
article.unpublish

# Article — retrieve by username + slug
article = client.articles.retrieve_by_path("username", "article-slug")

# User (admin actions)
user = client.users.retrieve(99)
user.suspend
user.unsuspend
user.add_limited;  user.remove_limited
user.add_trusted;  user.remove_trusted
user.add_spam;     user.remove_spam
user.unpublish

# AgentSession
session = client.agent_sessions.retrieve("session-id")
session.raw_url

# Survey poll responses (cursor-paginated)
survey = client.surveys.retrieve(3)
survey.poll_votes.auto_paging_each { |v| puts v.poll_option_id }
survey.poll_text_responses.each    { |r| puts r.text_content }
```

## Pagination

List-style endpoints return a `Forem::ListObject`, which is `Enumerable`
and carries pagination state.

```ruby
page = client.articles.list(per_page: 30)

page.each { |a| puts a.title }
page.has_more?              # => true / false
page.length                 # => 30
page[0]                     # => first item

next_page = page.next_page
prev_page = next_page.previous_page

# Iterate every item across pages, fetching as needed
client.articles.list(tag: "ruby").auto_paging_each { |a| puts a.title }
```

Cursor-paginated endpoints (e.g. `survey.poll_votes`) use the same
`ListObject` surface — `next_page` advances by cursor automatically;
`previous_page` returns `nil` (cursor pagination is forward-only).

## Admin user synchronization

Admin API keys can synchronize external identities and newsletter settings
through `client.admin_users`:

```ruby
identity = client.admin_users.link_identity(
  42,
  provider: "github",
  uid: "octocat"
)

client.admin_users.bulk_link_identities(
  provider: "github",
  identities: [
    { user_id: 42, uid: "octocat" },
    { user_id: 43, uid: "hubot" }
  ]
)

client.admin_users.identities(42).each { |item| puts item.uid }
client.admin_users.unlink_identity(42, identity.id)
client.admin_users.update_notification_settings(42, email_newsletter: false)
```

## Analytics response shapes

The four analytics endpoints don't share a uniform shape — `forem-ruby`
preserves the natural shape rather than forcing them into a list:

```ruby
totals = client.analytics.totals                              # => Forem::ForemObject
totals.reactions.total                                        # => 7
totals.page_views.total                                       # => 7

history = client.analytics.historical(start: "2026-04-01", end: "2026-04-30")
history.class                                                 # => Hash (keys: "YYYY-MM-DD")
history.each { |date, stats| puts "#{date}: #{stats.page_views.total}" }

day = client.analytics.past_day                               # => Hash<date, stats>
client.analytics.referrers.each { |r| puts "#{r.domain}: #{r.count}" }
```

## Health checks

In production the `/api/health_checks/*` endpoints require an
`health-check-token` header (separate from the `api-key` used everywhere
else). On localhost the Forem controller bypasses the token check, so a
local-development Forem accepts unauthenticated calls.

```ruby
# Production
client.health_checks.app(token: ENV.fetch("FOREM_HEALTH_CHECK_TOKEN"))

# Local development (token bypassed for localhost)
client.health_checks.app
```

## Error Handling

All errors inherit from `Forem::ForemError`, which exposes `http_status`,
`http_body`, `http_headers`, and `code`.

```
Forem::ForemError
  Forem::AuthenticationError   # 401
  Forem::AuthorizationError    # 403
  Forem::NotFoundError         # 404
  Forem::ConflictError         # 409
  Forem::InvalidRequestError   # 422
  Forem::RateLimitError        # 429
  Forem::APIError              # 5xx and other server errors
  Forem::APIConnectionError    # network-level failures
```

```ruby
begin
  article = client.articles.retrieve(99999)
rescue Forem::NotFoundError => e
  puts "Not found: #{e.message} (HTTP #{e.http_status})"
rescue Forem::AuthenticationError
  puts "Invalid API key"
rescue Forem::RateLimitError => e
  delay = e.retry_after ? "#{e.retry_after} seconds" : "a backoff delay"
  puts "Rate limited — retry after #{delay}"
rescue Forem::ForemError => e
  code = e.code || "unknown"
  puts "API error: #{code}: #{e.message}"
end
```

For JSON object error responses, `code` is populated from `error_code` when
present. `RateLimitError#retry_after` returns integer seconds from the
normalized `Retry-After` response header, or `nil` when the header is absent
or not an integer.

The client retries automatically on connection errors, rate limits, and 5xx
responses. Rate-limit retries honor integer `Retry-After` seconds and fall
back to jittered exponential backoff otherwise. See `max_network_retries` in
the configuration table below.

## Configuration

All configuration goes through `Forem::Client.new`. There is no global
configuration and no module-level state.

```ruby
client = Forem::Client.new(
  ENV.fetch("FOREM_API_KEY"),
  api_base:            "https://my.forem.instance",
  api_version:         "v1",
  open_timeout:        10,
  read_timeout:        60,
  max_network_retries: 3
)
```

| Option | Type | Default | Description |
|---|---|---|---|
| `api_key` (positional) | String | — | API key sent as the `api-key` request header |
| `api_base` | String | `"https://dev.to"` | Base URL of the Forem instance |
| `api_version` | String | `"v1"` | API version string (informational) |
| `open_timeout` | Integer | `30` | Seconds to wait for a TCP connection |
| `read_timeout` | Integer | `80` | Seconds to wait for a response |
| `max_network_retries` | Integer | `1` | Automatic retries on connection errors, rate limits, and 5xx responses |
| `log_level` | Symbol | `nil` | Log level (`:debug`, `:info`, etc.) |
| `logger` | Logger | `nil` | Custom logger instance |

## Per-Request Options

Override the API key (or base URL) for a single call by passing it in
the options hash on any service method:

```ruby
client.articles.retrieve(12345, api_key: "other_key")
```

## Requirements

- Ruby 3.1 or later
- No runtime dependencies (uses Ruby's built-in `net/http`)

## License

MIT
