namespace :debug do
  desc "interact with a recovery list"
  task :recovery_list, [:assessment_id] do |_, args|
    assessment_id = args[:assessment_id] || ENV["assessment_id"]
    recovery_list = gateway :recovery_list
    loop do
      puts "1) register with 3 retries; 2) register attempt; 3) remove assessment; 4) exit"
      input = $stdin.gets.strip
      case input
      when "1"
        recovery_list.register_assessments(assessment_id, queue: :assessments)
        puts "registered! retry count: #{recovery_list.retries_left(assessment_id:, queue: :assessments)}"
      when "2"
        recovery_list.register_attempt(assessment_id:, queue: :assessments)
        puts "registered attempt! retry count: #{recovery_list.retries_left(assessment_id:, queue: :assessments)}"
      when "3"
        recovery_list.remove_assessment(assessment_id, queue: :assessments)
        puts "removed! retry count: #{recovery_list.retries_left(assessment_id:, queue: :assessments)}"
      when "4"
        puts "bye!"
        break
      else
        puts "Unknown option!"
      end
    end
  end
end
