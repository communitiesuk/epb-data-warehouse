# frozen_string_literal: true

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

ruby "2.7.3"

source "https://rubygems.org" do
  group :test do
    gem "database_cleaner-active_record", "~> 2.0", ">= 2.0.1"
    gem "mock_redis", "~> 0.28.0"
    gem "rspec", "~> 3.10"
    gem "rubocop-govuk", "~> 4.0", require: false
    gem "rubocop-performance", "~> 1.11", ">= 1.11.4", require: false
    gem "webmock", "~> 3.14"
  end

  gem "activerecord", "~> 6.1", ">= 6.1.4"
  gem "activesupport", "~> 6.1", ">= 6.1.4"
  gem "epb-auth-tools", "~> 1.0", ">= 1.0.8"
  gem "epb_view_models", "~> 1.0", ">= 1.0.14"
  gem "nokogiri", "~> 1.12", ">= 1.12.5"
  gem "pg", "~> 1.2", ">= 1.2.3"
  gem "rake", "~> 13.0", ">= 13.0.6"
  gem "redis", "~> 4.4"
  gem "rexml", "~> 3.2", ">= 3.2.4"
  gem "zeitwerk", "~> 2.4", ">= 2.4.2"
end
