namespace :db do
  desc "Create migration"
  task :create_migration do
    name = ARGV[1] || raise("Specify name: rake g:migration your_migration")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    path = Dir.pwd + "/db/migrate/#{timestamp}_#{name}.rb"
    migration_class = name.split("_").map(&:capitalize).join

    File.open(path, "w") do |file|
      file.write <<~MIGRATION
        class #{migration_class} < ActiveRecord::Migration
          def self.up
          end
          def self.down
          end
        end
      MIGRATION
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end
