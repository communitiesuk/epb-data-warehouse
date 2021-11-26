namespace :scaffolding do
  desc "trigger an import of a specific RRN by pushing that RRN onto the import queue"
  task :trigger_rrn_import, [:rrn] do |_, args|
    queues = gateway(:queues)
    rrn = args[:rrn]
    queues.push_to_queue :assessments, rrn
    puts "pushed to queue!"
  end
end