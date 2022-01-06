require "active_record"
require "active_support"
require "active_support/core_ext/uri"
require "async"
require "zeitwerk"
require "epb_view_models"
require "nokogiri"
require "sentry-ruby"

require_relative "db/seeds"

unless defined? TestLoader
  require "zeitwerk"
  loader = Zeitwerk::Loader.new
  loader.push_dir("#{__dir__}/lib/")
  loader.push_dir("#{__dir__}/lib/helper", namespace: Helper)
  loader.setup
end

def use_case(name)
  Services.use_case name
end

def gateway(name)
  Services.gateway name
end

def report_to_sentry(exception)
  Sentry.capture_exception(exception) if defined?(Sentry)
end

Sentry.init do |config|
  config.environment = ENV["STAGE"]
  config.capture_exception_frame_locals = true
end

# Adds project rake files
Dir.glob("lib/tasks/**/*.rake").each { |r| load r }

# Loads Rails database tasks
Rake.load_rakefile("active_record/railties/databases.rake")

DATABASE_CONFIG = ActiveRecord::DatabaseConfigurations::ConnectionUrlResolver.new(ENV["DATABASE_URL"])
ActiveRecord::Base.establish_connection(DATABASE_CONFIG.to_hash)
