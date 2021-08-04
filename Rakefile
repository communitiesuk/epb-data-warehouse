require "pg" # postgresql
require "erb"
require "yaml"
require "active_record"
require "sinatra/activerecord"
require "zeitwerk"
require "redis"



loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.setup

desc "Sets up environment"
task :environment do
  RAKE_PATH = File.expand_path(".")
  RAKE_ENV  = ENV.fetch("APP_ENV", "development")
  ENV["RAILS_ENV"] = RAKE_ENV

  Bundler.require :default, RAKE_ENV

  ActiveRecord::Tasks::DatabaseTasks.database_configuration = ActiveRecord::Base.configurations
  ActiveRecord::Tasks::DatabaseTasks.root             = RAKE_PATH
  ActiveRecord::Tasks::DatabaseTasks.env              = RAKE_ENV
  ActiveRecord::Tasks::DatabaseTasks.db_dir           = "db"
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ["db/migrate"]
  ActiveRecord::Tasks::DatabaseTasks.seed_loader      = OpenStruct.new(load_seed: nil)
end

Dir.glob("lib/tasks/*.rake").each { |r| load r }

# Use Rails 6 migrations
load "active_record/railties/databases.rake"

namespace :db do
  desc "Generate migration"
  task :create_migration do
    name = ARGV[1] || raise("Specify name: rake g:migration your_migration")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split("_").map(&:capitalize).join

    File.open(path, "w") do |file|
      file.write <<-FILE
        class #{migration_class} < ActiveRecord::Migration
          def self.up
          end
          def self.down
          end
        end
      FILE
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end
