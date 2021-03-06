# Small script to run migrations (mainly for use in Travis CI)

# set correct rails version
rails_major_version = 3
rails_major_version = ENV["RAILS_VERSION"][0] unless ENV["RAILS_VERSION"].nil? 

# switch to dummy-app for rails version and run migrations
Dir.chdir("./spec/dummy-rails-#{rails_major_version}") do
  system "bundle exec rake db:migrate"
end