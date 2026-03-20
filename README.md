# forem-ruby

Ruby client for the [Forem API](https://developers.forem.com/api).

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

Configure globally, then call resources directly:

```ruby
require "forem"

Forem.configure do |c|
  c.api_key = "your_api_key"
end

# List published articles
articles = Forem::Article.list(tag: "ruby", per_page: 10)
articles.each { |a| puts a.title }

# Create an article
article = Forem::Article.create(
  article: {
    title: "Hello World",
    body_markdown: "## Hello\n\nThis is my article.",
    published: false
  }
)
puts article.id

# Retrieve a single article
article = Forem::Article.retrieve(12345)
puts article.title
```

## Client Instance

For multi-tenant usage or when you need separate configurations per request, use `Forem::Client`:

```ruby
client = Forem::Client.new("your_api_key")

# All resources are available as methods on the client
articles = client.articles.list(per_page: 5)
article  = client.articles.retrieve(12345)
user     = client.users.me
```

You can create multiple clients pointing to different Forem instances:

```ruby
devto  = Forem::Client.new("devto_key",  api_base: "https://dev.to")
custom = Forem::Client.new("custom_key", api_base: "https://my.forem.instance")
```

## Resources

The gem covers all 21 resources exposed by the Forem API. Each resource is available both as a class (global configuration) and as a service on `Forem::Client`.

| Client accessor | Class | Available operations |
|---|---|---|
| `client.articles` | `Forem::Article` | `list`, `create`, `retrieve`, `update`, `me`, `me_published`, `me_unpublished`, `me_all`, `latest`, `search`, `retrieve_by_path` |
| `client.users` | `Forem::User` | `retrieve`, `me`, `search` |
| `client.comments` | `Forem::Comment` | `list`, `retrieve` |
| `client.organizations` | `Forem::Organization` | `list`, `create`, `retrieve`, `update`, `delete` |
| `client.tags` | `Forem::Tag` | `list` |
| `client.follows` | `Forem::Follow` | `list`, `create` |
| `client.followers` | `Forem::Follower` | `list` |
| `client.reading_list` | `Forem::ReadingList` | `list` |
| `client.podcast_episodes` | `Forem::PodcastEpisode` | `list` |
| `client.videos` | `Forem::Video` | `list` |
| `client.profile_images` | `Forem::ProfileImage` | `retrieve` |
| `client.billboards` | `Forem::Billboard` | `list`, `create`, `retrieve`, `update` |
| `client.pages` | `Forem::Page` | `list`, `create`, `retrieve`, `update`, `delete` |
| `client.segments` | `Forem::Segment` | `list`, `create`, `retrieve`, `delete` |
| `client.reactions` | `Forem::Reaction` | `create`, `toggle` |
| `client.recommended_articles_lists` | `Forem::RecommendedArticlesList` | `list`, `create`, `retrieve`, `update` |
| `client.agent_sessions` | `Forem::AgentSession` | `list`, `create`, `retrieve`, `presign` |
| `client.surveys` | `Forem::Survey` | `list`, `retrieve` |
| `client.analytics` | `Forem::Analytics` | `totals`, `historical`, `past_day`, `referrers` |
| `client.health_checks` | `Forem::HealthCheck` | `app`, `database`, `cache` |
| `client.admin_users` | `Forem::AdminUser` | `create` |

### Instance methods on retrieved objects

Some resources expose additional actions on the retrieved object:

```ruby
# Article
article = Forem::Article.retrieve(12345)
article.unpublish

# Article — retrieve by username + slug
article = Forem::Article.retrieve_by_path("username", "article-slug")

# User (admin actions)
user = Forem::User.retrieve(99)
user.suspend
user.unsuspend
user.add_limited
user.remove_limited
user.add_trusted
user.remove_trusted
user.add_spam
user.remove_spam
user.unpublish

# AgentSession
session = Forem::AgentSession.retrieve("session-id")
session.raw_url
```

## Pagination

`list` calls return a `Forem::ListObject`, which is `Enumerable` and carries pagination state.

```ruby
page = Forem::Article.list(per_page: 30)

# Iterate the current page
page.each { |a| puts a.title }

# Check whether more pages exist
page.has_more?  # => true / false

# Fetch adjacent pages manually
next_page = page.next_page
prev_page = next_page.previous_page

# Iterate all pages automatically
Forem::Article.list(tag: "ruby", per_page: 30).auto_paging_each do |article|
  puts article.title
end
```

## Error Handling

All errors inherit from `Forem::ForemError`, which exposes `http_status`, `http_body`, `http_headers`, and `code`.

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
  article = Forem::Article.retrieve(99999)
rescue Forem::NotFoundError => e
  puts "Not found: #{e.message} (HTTP #{e.http_status})"
rescue Forem::AuthenticationError
  puts "Invalid API key"
rescue Forem::RateLimitError
  puts "Rate limited — back off and retry"
rescue Forem::ForemError => e
  puts "API error: #{e.message}"
end
```

The client retries automatically on connection errors and 5xx responses. See `max_network_retries` in the configuration table below.

## Configuration

Configure global defaults via `Forem.configure`:

```ruby
Forem.configure do |c|
  c.api_key             = "your_api_key"
  c.api_base            = "https://dev.to"
  c.api_version         = "v1"
  c.open_timeout        = 30
  c.read_timeout        = 80
  c.max_network_retries = 2
  c.log_level           = :info
  c.logger              = Logger.new($stdout)
end
```

| Option | Type | Default | Description |
|---|---|---|---|
| `api_key` | String | `nil` | API key sent as the `api-key` request header |
| `api_base` | String | `"https://dev.to"` | Base URL of the Forem instance |
| `api_version` | String | `"v1"` | API version string (informational) |
| `open_timeout` | Integer | `30` | Seconds to wait for a TCP connection |
| `read_timeout` | Integer | `80` | Seconds to wait for a response |
| `max_network_retries` | Integer | `1` | Automatic retries on connection errors and 5xx responses |
| `log_level` | Symbol | `nil` | Log level (`:debug`, `:info`, etc.) |
| `logger` | Logger | `nil` | Custom logger instance |

The same options are accepted as keyword arguments to `Forem::Client.new`:

```ruby
client = Forem::Client.new(
  "your_api_key",
  api_base:            "https://my.forem.instance",
  open_timeout:        10,
  max_network_retries: 3
)
```

## Per-Request Options

Override the API key for a single call by passing `api_key:` in the options hash:

```ruby
# Global key is configured, but override for this one call
article = Forem::Article.retrieve(12345, api_key: "other_key")

# Same via the client
article = client.articles.retrieve(12345, api_key: "other_key")
```

## Requirements

- Ruby 3.1 or later
- No runtime dependencies (uses Ruby's built-in `net/http`)

## License

MIT
