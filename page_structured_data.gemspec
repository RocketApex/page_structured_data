require_relative "lib/page_structured_data/version"

Gem::Specification.new do |spec|
  spec.name        = "page_structured_data"
  spec.version     = PageStructuredData::VERSION
  spec.authors     = ["Jey Geethan"]
  spec.email       = ["opensource@rocketapex.com"]

  spec.summary       = "Easily create meta tags with structured data for webpages"
  spec.description   = "Easily create meta tags with structured data for webpages"
  spec.homepage      = "https://github.com/RocketApex/page_structured_data"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/RocketApex/page_structured_data"
  spec.metadata["changelog_uri"] = "https://github.com/RocketApex/page_structured_data"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.0"
  spec.add_dependency "slim"
end
