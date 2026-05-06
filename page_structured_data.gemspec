require_relative "lib/page_structured_data/version"

Gem::Specification.new do |spec|
  spec.name        = "page_structured_data"
  spec.version     = PageStructuredData::VERSION
  spec.authors     = ["Jey Geethan"]
  spec.email       = ["opensource@rocketapex.com"]

  spec.summary       = "Render SEO, social, and JSON-LD metadata for Rails pages"
  spec.description   = "PageStructuredData gives Rails applications a small page object and view partial for rendering page titles, basic meta tags, Open Graph tags, Twitter card tags, breadcrumb JSON-LD, article and forum post JSON-LD, Person, Organization, and WebSite JSON-LD, and public interaction statistics."
  spec.homepage      = "https://github.com/RocketApex/page_structured_data"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/RocketApex/page_structured_data"
  spec.metadata["documentation_uri"] = "https://github.com/RocketApex/page_structured_data#readme"
  spec.metadata["bug_tracker_uri"] = "https://github.com/RocketApex/page_structured_data/issues"
  spec.metadata["changelog_uri"] = "https://github.com/RocketApex/page_structured_data/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "CHANGELOG.md", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.0", "< 9.0"
end
