desc "Import assessments fixture into to the dev database for testing"
task :seed_average_co2_emissions do
  Gateway::DocumentsGateway::AssessmentDocument.delete_all

  json_dir_path = File.join(Dir.pwd, "spec/fixtures/json_export/")

  rrn = "0000-0000-0000-0000-0000"

  sap = JSON.parse(File.read("#{json_dir_path}sap.json"))
  rdsap = JSON.parse(File.read("#{json_dir_path}rdsap.json"))
  epcs = [sap, rdsap]

  next_id = proc do |_assessment_id|
    next_number = BigDecimal(rrn.delete("-")) + BigDecimal("1")
    next_number.truncate.to_s.rjust(20, "0").scan(/.{4}/).join("-")
  end

  epcs.each do |certificate|
    30.times do |i|
      date = Time.now.to_date - (i + 1).days
      rrn = next_id.call rrn
      certificate["co2_emissions_current_per_floor_area"] = Random.new.rand(20..100)
      certificate["registration_date"] = date
      certificate["assessment_type"] = certificate["type_of_assessment"]
      Container.import_certificate_data_use_case.execute(assessment_id: rrn, certificate_data: certificate)
      Gateway::AssessmentsCountryIdGateway.new.insert(assessment_id: rrn, country_id: 1)
    end
  end
end
