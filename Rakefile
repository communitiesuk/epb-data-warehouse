require "active_record"
require "active_support"
require "active_support/core_ext/uri"
require "zeitwerk"
require "epb_view_models"
require "nokogiri"

require_relative "db/seeds"

unless defined? TestLoader
  require "zeitwerk"
  loader = Zeitwerk::Loader.new
  loader.push_dir("#{__dir__}/lib/")
  loader.push_dir("#{__dir__}/lib/helper", namespace: Helper)
  loader.setup
end

# Adds project rake files
Dir.glob("lib/tasks/**/*.rake").each { |r| load r }

# Loads Rails database tasks
Rake.load_rakefile("active_record/railties/databases.rake")

DATABASE_CONFIG = ActiveRecord::DatabaseConfigurations::ConnectionUrlResolver.new(ENV["DATABASE_URL"])
ActiveRecord::Base.establish_connection(DATABASE_CONFIG.to_hash)
