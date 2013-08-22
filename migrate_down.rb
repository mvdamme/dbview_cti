# Small script to roll back migrations (mainly for use in Travis CI)
# (we do this to make sure 'rake db:rollback' is also tested)

# set correct rails version
rails_major_version = 3
rails_major_version = ENV["RAILS_VERSION"][0] unless ENV["RAILS_VERSION"].nil? 

# switch to dummy-app for rails version and run migrations
Dir.chdir("./spec/dummy-rails-#{rails_major_version}") do
  1.upto(Dir.glob('./db/migrate/*.rb').length) do
    system "rake db:rollback"
  end
end