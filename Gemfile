source "http://rubygems.org"

# Declare your gem's dependencies in view_based_cti.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

# taken from http://schneems.com/post/50991826838/testing-against-multiple-rails-versions
rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "master"
  { :github => "rails/rails"}
when "default"
  ">= 3.2.13"
else
  "~> #{rails_version}"
end

gem "rails", rails

group :test, :development do
  gem "activerecord-postgresql-adapter", :platforms => [:ruby, :mswin, :mingw]
  gem "activerecord-jdbcpostgresql-adapter", :platforms => [:jruby]  
end
