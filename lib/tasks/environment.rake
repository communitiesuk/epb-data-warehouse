# NOTE: this is called by db:create and db:migrate tasks
desc "Configure database tasks (normally done by Rails)"
task :environment do
  pp "TASK ENVIRONMENT START; ENV="
  ActiveRecord::Tasks::DatabaseTasks.db_dir = "db"
  pp "  Done db_dir"
  ActiveRecord::Tasks::DatabaseTasks.env = ENV["RAILS_ENV"]
  pp "  Done env"
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = "db/migrate"
  pp "  Done migrations paths"
  ActiveRecord::Tasks::DatabaseTasks.database_configuration = DATABASE_CONFIG.to_hash
  pp "  Done configuration"
  ActiveRecord::Tasks::DatabaseTasks.seed_loader = LookupSeed.new
  pp "  Done seedloader"
  pp "TASK ENVIRONMENT END"
end
