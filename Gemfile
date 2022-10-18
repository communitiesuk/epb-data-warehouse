# frozen_string_literal: true

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby "3.1.2"

source "https://rubygems.org"
group :test do
  gem "database_cleaner-active_record", "~> 2.0", ">= 2.0.1"
  gem "mock_redis", "~> 0.34"
  gem "rspec", "~> 3.10"
  gem "rubocop-govuk", "~> 4.6", require: false
  gem "rubocop-performance", "~> 1.15", require: false
  gem "timecop", "~> 0.9.5"
  gem "webmock", "~> 3.17"
end

gem "activerecord", "~> 7.0"
gem "activesupport", "~> 7.0"
gem "async", "~> 2.2"
gem "concurrent-ruby", "~> 1.1"
gem "epb-auth-tools", "~> 1.0.11"
gem "epb_view_models", "~> 1.0"
gem "nokogiri", "~> 1.13"
gem "parallel", "~> 1.22"
gem "pg", "~> 1.4"
gem "rake", "~> 13.0", ">= 13.0.6"
gem "redis", "~> 5.0"
gem "rexml", "~> 3.2", ">= 3.2.4"
gem "sentry-ruby", "~> 5.4"
gem "unleash", "~> 4.4.0"
gem "zeitwerk", "~> 2.6"
