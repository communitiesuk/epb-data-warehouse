desc "trigger an import of a specific RRN by pushing that RRN onto the import queue"
task :trigger_rrn_import, [:rrn] do |_, args|
  queues = gateway(:queues)
  rrn = args[:rrn] || ENV["rrn"]
  queues.push_to_queue :assessments, rrn, jump_queue: true
  puts "pushed #{rrn} to queue!"
end
