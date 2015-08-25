# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'abn_search/version'

Gem::Specification.new do |s|
  s.name        = "abn_search"
  s.version     = ABNSearch::VERSION
  s.authors     = ["James Martin", "Stuart Auld", "James Healy"]
  s.email       = ["james@visualconnect.net", "sja@marsupialmusic.net", "jimmy@deefa.com"]
  s.homepage    = "https://github.com/sjauld/abn_search"
  s.summary     = "ABR Search library for Australian businesses."
  s.description = "A simple ABN search library for validating and obtaining ABN details from the Australian Business Register."
  s.rubyforge_project = "abn_search"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'savon',       '~> 2.11'
  s.add_dependency 'nokogiri',    '~> 1.6'
  s.add_development_dependency("yard")
  s.add_development_dependency 'rspec', '>=0'
  s.add_development_dependency 'dotenv', '>=0'
end
