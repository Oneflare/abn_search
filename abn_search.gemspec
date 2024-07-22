# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "abn/version"

Gem::Specification.new do |s|
  s.name        = "abn_search"
  s.version     = Abn::VERSION
  s.authors     = ["James Martin"]
  s.email       = ["james@oneflare.com"]
  s.homepage    = "https://github.com/oneflare/abn_search"
  s.summary     = "ABN Search library for Australian businesses."
  s.description = "A simple ABN search library for validating and obtaining ABN details from the " \
                  "Australian Business Register."
  s.license     = "MIT"
  s.rubyforge_project = "abn_search"

  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency("savon", "~> 2.6")
  s.add_dependency("httparty", "~> 0")
  s.add_dependency("nokogiri", "~> 1.6")
  s.add_development_dependency "coveralls_reborn", "~> 0.28.0"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "rspec", "~> 3.5", ">= 3.0"
  s.add_development_dependency "rspec_junit_formatter", "~> 0.2"
  s.add_development_dependency "simplecov", "~> 0"
  s.add_development_dependency("yard", "~> 0.8")
  s.add_development_dependency("pry-byebug", "~> 3")
end
