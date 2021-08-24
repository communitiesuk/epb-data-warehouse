# NOTE: this is called by db:create and db:migrate tasks
desc "Configure database tasks (normally done by Rails)"
task :pipeline_test do
  pp ENV
end
