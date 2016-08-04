$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'abn/version'

Gem::Specification.new do |s|
  s.name        = "abn_search"
  s.version     = Abn::VERSION
  s.authors     = ["James Martin"]
  s.email       = ["james@oneflare.com"]
  s.homepage    = "https://github.com/oneflare/abn_search"
  s.summary     = "ABN Search library for Australian businesses."
  s.description = "A simple ABN search library for validating and obtaining ABN details from the Australian Business Register."
  s.rubyforge_project = "abn_search"
  s.license     = "MIT"

  s.files = Dir['{lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency("savon")
  s.add_dependency("nokogiri")
  s.add_development_dependency("yard")
end