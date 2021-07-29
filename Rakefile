load 'app.rb'

task :environment do
  RAKE_PATH = File.expand_path('.')
  RAKE_ENV  = ENV.fetch('APP_ENV', 'development')
  ENV['RAILS_ENV'] = RAKE_ENV

  Bundler.require :default, RAKE_ENV

  ActiveRecord::Tasks::DatabaseTasks.database_configuration = ActiveRecord::Base.configurations
  ActiveRecord::Tasks::DatabaseTasks.root             = RAKE_PATH
  ActiveRecord::Tasks::DatabaseTasks.env              = RAKE_ENV
  ActiveRecord::Tasks::DatabaseTasks.db_dir           = 'db'
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ['db/migrate']
  ActiveRecord::Tasks::DatabaseTasks.seed_loader      = OpenStruct.new(load_seed: nil)
end

# Use Rails 6 migrations
load 'active_record/railties/databases.rake'
