# frozen_string_literal: true

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby "3.1.3"

source "https://rubygems.org"
group :test do
  gem "database_cleaner-active_record", "~> 2.1"
  gem "mock_redis", "~> 0.39"
  gem "rspec", "~> 3.12"
  gem "rubocop-govuk", "~> 4.12", require: false
  gem "rubocop-performance", "~> 1.19", require: false
  gem "timecop", "~> 0.9.8"
  gem "webmock", "~> 3.19"
end

gem "activerecord", "~> 7.1"
gem "activesupport", "~> 7.1"
gem "async", "~> 2.6"
gem "concurrent-ruby", "~> 1.2"
gem "epb-auth-tools", "~> 1.1.0"
gem "epb_view_models", "~> 1.1"
gem "nokogiri", "~> 1.15"
gem "parallel", "~> 1.23"
gem "pg", "~> 1.5"
gem "rake", "~> 13.1"
gem "redis", "~> 5.0"
gem "rexml", "~> 3.2"
gem "sentry-ruby", "~> 5.13"
gem "unleash", "~> 5.0.0"
gem "zeitwerk", "~> 2.6"
