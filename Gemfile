# frozen_string_literal: true

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby "4.0.10"

source "https://rubygems.org"
group :test do
  gem "database_cleaner-active_record", "~> 2.1"
  gem "mock_redis", "~> 0.56"
  gem "rack-test", "~> 2.3.0"
  gem "rspec", "~> 3.12"
  gem "rspec-snapshot", "~> 2.2"
  gem "rubocop-govuk", "~> 5.2", require: false
  gem "rubocop-performance", "~> 1.21", require: false
  gem "simplecov", "~>1.3.2"
  gem "timecop", "~> 0.9"
  gem "webmock", "~> 3.34"
end

group :development do
  gem "sinatra-contrib"
end

group :rake do
  gem "notifications-ruby-client", "~> 6.5"
end

gem "activerecord", "~> 8.1"
gem "activesupport", "~> 8.1"
gem "async", "~> 2.46"
gem "aws-sdk-dynamodb", "~> 1.186"
gem "aws-sdk-kms", "~> 1"
gem "aws-sdk-s3", "1.242.0"
gem "benchmark"
gem "concurrent-ruby", "~> 1.3"
gem "csv", "~> 3.3"
gem "epb-auth-tools", "~> 1.2.1"
gem "epb_view_models", "~> 2.9.2"
gem "json-schema", "~> 6.2"
gem "nokogiri", "~> 1.19"
gem "parallel", "~> 1.28"
gem "pg", "~> 1.7"
gem "puma", "~> 8.0"
gem "rackup", "~> 2.1"
gem "rake", "~> 13.4"
gem "redis", "~> 5.3"
gem "rexml", "~> 3.3"
gem "rubyzip", "~> 3.7"
gem "sentry-ruby", "~> 7.2"
gem "sinatra", "~> 4.2"
gem "sinatra-activerecord", "~> 2.0.28"
gem "unleash", "~> 6.7.1"
gem "zeitwerk", "~> 2.8"
