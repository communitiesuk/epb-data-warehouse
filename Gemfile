# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# gem "rails"
gem "activerecord"
gem "aws-sdk-s3", "~> 1.96"
gem "database_cleaner"
gem "epb-auth-tools", "~> 1.0.8"
gem "epb_view_models", "~> 1.0.1"
gem "erb", "~> 2.2", ">= 2.2.3"
gem "geocoder", "~> 1.6.6"
gem "json-schema", "~> 2.8"
gem "nokogiri", "~> 1.11.7"
gem "ougai", "~> 2.0"
gem "pg"
gem "pry", "~> 0.14.1"
gem "rake"
gem "redis", "~> 4.3.1"
gem "rspec"
gem "rubocop-govuk", "~> 3.17"
gem "rubocop-performance", require: false
gem "sinatra-activerecord"
gem "timecop", "~> 0.9.4"
gem "webmock", "~> 3.13"
gem "yaml", "~> 0.1.1"
gem "zeitwerk", "~> 2.4.1"

group :worker do
  gem "sidekiq", "~> 6.2.1"
  gem "sidekiq-cron", "~> 1.2.0"
end
