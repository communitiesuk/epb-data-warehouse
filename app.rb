require "pg" # postgresql
require "erb"
require "yaml"
require "active_record"

APP_ENV = ENV.fetch("APP_ENV", "development")

db_config = YAML.load(File.open("config/database.yml"))
ActiveRecord::Base.establish_connection(db_config)
