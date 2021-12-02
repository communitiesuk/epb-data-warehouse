# NOTE: this is called by db:create and db:migrate tasks
desc "Configure database tasks (normally done by Rails)"
task :test_prod do
  result =  ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as cnt FROM assessment_attributes").first
  pp "There are #{result["cnt"]} assessment values in the db"
end
