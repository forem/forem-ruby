require_relative "lib/forem/version"

Gem::Specification.new do |s|
  s.name = "forem-ruby"
  s.version = Forem::VERSION
  s.required_ruby_version = ">= 3.1.0"
  s.summary = "Ruby client for the Forem API"
  s.description = "A Ruby client library for the Forem API, modeled after stripe-ruby patterns."
  s.authors = ["Forem"]
  s.homepage = "https://github.com/forem/forem-ruby"
  s.license = "MIT"
  s.files = Dir["lib/**/*.rb"] + ["forem-ruby.gemspec", "LICENSE"]
  s.require_paths = ["lib"]
  s.metadata = {
    "rubygems_mfa_required" => "true",
    "homepage_uri" => "https://github.com/forem/forem-ruby",
    "source_code_uri" => "https://github.com/forem/forem-ruby",
    "bug_tracker_uri" => "https://github.com/forem/forem-ruby/issues",
    "documentation_uri" => "https://rubydoc.info/gems/forem-ruby",
  }
end
