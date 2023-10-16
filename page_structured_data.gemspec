# frozen_string_literal: true

require_relative "lib/page_structured_data/version"

Gem::Specification.new do |spec|
  spec.name          = "page_structured_data"
  spec.version       = PageStructuredData::VERSION
  spec.authors       = ["Jey Geethan"]
  spec.email         = ["opensource@rocketapex.com"]

  spec.summary       = "Easily create meta tags with structured data for webpages"
  spec.description   = "Easily create meta tags with structured data for webpages"
  spec.homepage      = "https://github.com/RocketApex/page_structured_data"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/RocketApex/page_structured_data"
  spec.metadata["changelog_uri"] = "https://github.com/RocketApex/page_structured_data"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
