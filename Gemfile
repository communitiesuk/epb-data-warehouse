# frozen_string_literal: true

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby "3.3.4"

source "https://rubygems.org"
group :test do
  gem "database_cleaner-active_record", "~> 2.1"
  gem "mock_redis", "~> 0.41"
  gem "rack-test", "~> 2.1.0"
  gem "rspec", "~> 3.12"
  gem "rubocop-govuk", "~> 5.0", require: false
  gem "rubocop-performance", "~> 1.21", require: false
  gem "timecop", "~> 0.9"
  gem "webmock", "~> 3.23"
end

group :development do
  gem "sinatra-contrib"
end

group :rake do
  gem "notifications-ruby-client", "~> 6.1"
end

gem "activerecord", "~> 7.2"
gem "activesupport", "~> 7.2"
gem "async", "~> 2.15"
gem "aws-sdk-s3", "~> 1"
gem "concurrent-ruby", "~> 1.3"
gem "csv", "~> 3.3"
gem "epb-auth-tools", "~> 1.1.0"
gem "epb_view_models", "~> 2.0"
gem "nokogiri", "~> 1.16"
gem "parallel", "~> 1.26"
gem "pg", "~> 1.5"
gem "puma", "~> 6.4"
gem "rackup", "~> 2.1"
gem "rake", "~> 13.2"
gem "redis", "~> 5.3"
gem "rexml", "~> 3.3"
gem "sentry-ruby", "~> 5.17"
gem "sinatra", "~> 4.0"
gem "sinatra-activerecord", "~> 2.0.27"
gem "unleash", "~> 5.0.1"
gem "zeitwerk", "~> 2.6"
