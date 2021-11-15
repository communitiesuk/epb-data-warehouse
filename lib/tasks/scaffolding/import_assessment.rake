namespace :scaffolding do
  desc "Import a specific assessment from the Register API, by RRN (temporary scaffolding)"
  task :import_assessment, [:rrn] do |_, args|
    assessment_id = args[:rrn] || abort("specify the assessment to import, e.g.: rake scaffolding:import_assessment[0000-0000-0000-0000-0001]")
    puts "attempting to import RRN #{assessment_id}..."
    fetch = use_case :fetch_certificate
    pp fetch.execute(assessment_id)
  end
end
