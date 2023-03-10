desc "trigger an import of a comma-separated list of specific RRNs by pushing those RRNs onto the import queue"
task :trigger_rrn_import, [:rrns_csv] do |_, args|
  queues = gateway(:queues)
  rrns = args[:rrns_csv].split(",")
  queues.push_to_queue :assessments, rrns, jump_queue: true
  puts "pushed #{rrns} to queue!"
end
