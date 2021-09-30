require "active_record"
require "active_support"
require "active_support/core_ext/uri"
require "zeitwerk"

require_relative "db/seeds"

pp "RAKE setting up loader"
loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib")
loader.setup

# Adds project rake files
pp "RAKE add lib/tasks"
Rake.add_rakelib("lib/tasks")

# Loads Rails database tasks
pp "RAKE load rakefile"
Rake.load_rakefile("active_record/railties/databases.rake")

pp "Rake reading db config"
DATABASE_CONFIG = ActiveRecord::DatabaseConfigurations::ConnectionUrlResolver.new(ENV["DATABASE_URL"])
pp "Rake got DATABASE_CONFIG with keys #{DATABASE_CONFIG.to_hash.keys}"
pp "Adapter: #{DATABASE_CONFIG.to_hash[:adapter]}, Username: #{DATABASE_CONFIG.to_hash[:username]}, Host: #{DATABASE_CONFIG.to_hash[:host]}, Database: #{DATABASE_CONFIG.to_hash[:database]}"
ActiveRecord::Base.establish_connection(DATABASE_CONFIG.to_hash)
pp "Rake established connection"
