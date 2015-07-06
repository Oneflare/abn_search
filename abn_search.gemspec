# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "abn_search"
  s.version     = '1.0.0'
  s.authors     = ["James Martin", "Stuart Auld"]
  s.email       = ["james@visualconnect.net", "sja@marsupialmusic.net"]
  s.homepage    = "https://github.com/Oneflare/abn_search"
  s.summary     = "ABR Search library for Australian businesses."
  s.description = "A simple ABN search library for validating and obtaining ABN details from the Australian Business Register."
  s.rubyforge_project = "abn_search"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("savon")
  s.add_dependency("nokogiri")
  s.add_development_dependency("yard")
end
