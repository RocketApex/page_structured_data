ENV["BUNDLE_GEMFILE"] ||= File.expand_path("gemfiles/Gemfile", __dir__)
require "bundler/setup"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

desc "Run the complete test suite"
task :test do
  ruby File.expand_path("bin/rails", __dir__), "test"
end
