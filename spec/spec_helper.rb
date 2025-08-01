# frozen_string_literal: true

require "epb_view_models"
require "epb-auth-tools"
require "active_support"
require "active_support/core_ext"
require "active_record"
require "async"
require "database_cleaner/active_record"
require "rack/test"
require "rake"
require "nokogiri"
require "concurrent"
require "mock_redis"
require "webmock/rspec"
require "timecop"

require_relative "samples"
require_relative "test_loader"

# See Gateway::ApiClient
ENV["EPB_AUTH_CLIENT_ID"] = "test.id"
ENV["EPB_AUTH_CLIENT_SECRET"] = "test.client.secret"
ENV["EPB_AUTH_SERVER"] = "http://test-auth-server.gov.uk"
ENV["EPB_API_URL"] = "http://test-api.gov.uk"
ENV["EPB_QUEUES_URI"] = "redis://127.0.0.1:6379"
ENV["JWT_ISSUER"] = "test.issuer"
ENV["JWT_SECRET"] = "test.secret"

ENV["RACK_ENV"] = "test"

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: %w[
    find-energy-certificate.local.gov.uk
    getting-new-energy-certificate.local.gov.uk
  ],
)

module RSpecDataWarehouseApiServiceMixin
  include Rack::Test::Methods

  class Countries < ActiveRecord::Base
  end

  def app
    DataWarehouseApiService
  end
end

def get_task(name)
  rake = Rake::Application.new
  Rake.application = rake
  rake.load_rakefile
  rake.tasks.find { |task| task.to_s == name }
end

def use_case(name)
  Services.use_case name
end

def gateway(name)
  Services.gateway name
end

def report_to_sentry(_); end

def get_valid_jwt(scopes = [], sup = {})
  token =
    Auth::Token.new(iat: Time.now.to_i,
                    exp: Time.now.to_i + (60 * 60),
                    iss: ENV["JWT_ISSUER"],
                    sub: "test-subject",
                    scopes:,
                    sup:)

  token.encode ENV["JWT_SECRET"]
end

def add_countries
  ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE countries RESTART IDENTITY CASCADE", "SQL")

  file_path = File.join Dir.pwd, "spec/config/countries.json"
  country_values = JSON.parse(File.read(file_path), symbolize_names: true)
  ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE countries RESTART IDENTITY CASCADE", "SQL")
  country_values.each do |item|
    Countries.create(country_id: item[:country_id], country_name: item[:country_name], address_base_country_code: item[:address_base_country_code], country_code: item[:country_code])
  end
end

def clear_materialized_views
  Gateway::MaterializedViewsGateway.new.fetch_all.each do |view|
    sql = "REFRESH MATERIALIZED VIEW #{view} WITH NO DATA;"
    ActiveRecord::Base.connection.exec_query(sql, "SQL")
  end
end

ENV["DATABASE_URL"] = "postgresql://postgres:#{ENV['DOCKER_POSTGRES_PASSWORD']}@localhost:5432/epb_eav_test"
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  config.before do
    DatabaseCleaner.strategy = [:truncation, { only: %w[assessment_attribute_values assessment_documents assessments_country_ids assessment_search audit_logs] }]
    DatabaseCleaner.start
  end

  config.before do
    allow(Helper::Toggles).to receive(:enabled?).and_return(true)
  end

  config.before do
    Container.reset!
  end

  config.before(:all, :set_with_timecop) { Timecop.freeze(Time.utc(2021, 12, 13)) }

  config.after(:all, :set_with_timecop) { Timecop.return }

  config.after(:all) { DatabaseCleaner.clean }
end
