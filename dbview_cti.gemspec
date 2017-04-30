$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "db_view_cti/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dbview_cti"
  s.version     = DBViewCTI::VERSION
  s.authors     = ["Michaël Van Damme"]
  s.email       = ["michael.vandamme@vub.ac.be"]
  s.homepage    = "https://github.com/mvdamme/dbview_cti"
  s.summary     = "Class Table Inheritance (CTI) for Rails."
  s.description = "This gem implements Class Table Inheritance (CTI) for Rails using database views."
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency "rails", ">= 3.2.0"

  s.add_development_dependency "rspec-rails", "~> 3.5"
  if ENV["RAILS_VERSION"] && ENV["RAILS_VERSION"][0].to_i < 5
    s.add_development_dependency "foreigner"
  end
end
