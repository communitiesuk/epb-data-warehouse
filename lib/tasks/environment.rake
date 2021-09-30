# NOTE: this is called by db:create and db:migrate tasks
desc "Configure database tasks (normally done by Rails)"
task :environment do
  ActiveRecord::Tasks::DatabaseTasks.db_dir = "db"
  ActiveRecord::Tasks::DatabaseTasks.env = ENV["RAILS_ENV"] || "default_env"
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = "db/migrate"
  ActiveRecord::Tasks::DatabaseTasks.database_configuration = DATABASE_CONFIG.to_hash
  ActiveRecord::Tasks::DatabaseTasks.seed_loader = LookupSeed.new
end
