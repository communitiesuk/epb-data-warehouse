desc "trigger an import of a specific RRN by pushing that RRN onto the import queue"
task :trigger_assessment_ids_import, [:assessment_ids] do |_, args|
  assessment_ids = args.assessment_ids || ENV["assessment_ids"]
  raise Boundary::ArgumentMissing, "assessment_ids" unless assessment_ids

  queues = Container.queues_gateway
  rrn_array = assessment_ids.gsub(/[[:space:]]/, "").split(",")
  # rrn_array.each do |rrn|
  #   raise Boundary::InvalidRrn, rrn unless Regexp.new(Helper::RegexHelper::RRN).match?(rrn)
  queues.push_to_queue :assessments, rrn_array, jump_queue: true

  puts "pushed #{rrn_array.count} assessment_ids to queue!"
end
