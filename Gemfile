source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.0"

# Use Puma as the app server
gem "puma", "~> 5.0"

# MongoDB driver
gem "mongoid", "~> 8.0"

# HTTP client for proxy testing
gem "httparty", "~> 0.21"

# Background job scheduler
gem "rufus-scheduler", "~> 3.9"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS)
gem "rack-cors"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
