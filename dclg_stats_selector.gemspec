$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dclg_stats_selector/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dclg_stats_selector"
  s.version     = DclgStatsSelector::VERSION
  s.authors     = ["Ric Roberts", "Bill Roberts", "Asa Calow", "Ash Moran"]
  s.email       = ["ric@swirrl.com"]
  s.homepage    = "http://swirrl.com"
  s.summary     = "DCLG Stats Selector engine"
  s.description = "An engine providing .csv (spreadsheet) geographical stats building functionality using linked data, to be used in conjunction with PublishMyData community edition."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  s.add_dependency "jquery-rails"
  s.add_dependency "haml"
  s.add_dependency "sparql-client"
  s.add_dependency "jquery-rails"
  s.add_dependency "sass"
end
