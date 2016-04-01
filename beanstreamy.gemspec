$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "beanstreamy/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "beanstreamy"
  s.version     = Beanstreamy::VERSION
  s.authors     = ["Jeff Siegel"]
  s.email       = ["jeff@stage2.ca"]
  s.homepage    = "https://github.com/jdsiegel/beanstreamy"
  s.summary     = "A Beanstream utility library for Rails and ActiveMerchant"
  s.description = "Adds activemerchant gateway support for hash validation, querying transactions, and submitting payment via hosted forms}"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "capybara", "~> 1.1"
end
