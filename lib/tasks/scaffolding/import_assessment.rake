namespace :scaffolding do
  desc "Import a specific assessment from the Register API, by RRN (temporary scaffolding)"
  task :import_assessment, [:rrn] do |_, args|
    assessment_id = args[:rrn] || abort("specify the assessment to import, e.g.: rake scaffolding:import_assessment[0000-0000-0000-0000-0001]")
    puts "attempting to import RRN #{assessment_id}..."
    gateway = gateway(:register_api)
    begin
      pp gateway.fetch(assessment_id)
      pp gateway.fetch_meta_data(assessment_id)
    rescue Errors::AssessmentDoesNotExist
      puts "...wasn't imported as could not be found!"
    end
  end
end
