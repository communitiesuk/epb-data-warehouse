require_relative "../../spec/samples"
desc "Import assessments fixture into to the dev database for testing"
task :seed_test_data do
  Tasks::TaskHelpers.quit_if_production
  country_id = 1
  documents_gateway = Gateway::DocumentsGateway.new

  pp "Loading RdSAP samples"

  created_at = Time.now
  assessment_index = 0

  rdsap_versions = %w[RdSAP-Schema-17.0 RdSAP-Schema-17.1 RdSAP-Schema-18.0 RdSAP-Schema-19.0 RdSAP-Schema-20.0.0 RdSAP-Schema-21.0.0 RdSAP-Schema-21.0.1]
  rdsap_versions.each do |version|
    assessment_id = "1111-0000-0000-0000-#{assessment_index.to_s.rjust(4, '0')}"
    load_sample_document(documents_gateway:, schema: version, assessment_id:, assessment_type: "RdSAP", sample_type: "epc", country_id:, created_at:, postcode: "SW10 0AA")
    assessment_index += 1
  end

  pp "Loading SAP samples"

  sap_versions_sap = %w[SAP-Schema-15.0 SAP-Schema-16.0 SAP-Schema-16.1 SAP-Schema-16.2 SAP-Schema-16.3]
  sap_versions_epc = %w[SAP-Schema-17.0 SAP-Schema-17.1 SAP-Schema-18.0.0 SAP-Schema-19.0.0 SAP-Schema-19.1.0]

  sap_versions_sap.each do |version|
    assessment_id = "2222-0000-0000-0000-#{assessment_index.to_s.rjust(4, '0')}"
    load_sample_document(documents_gateway:, schema: version, assessment_id:, assessment_type: "SAP", sample_type: "sap", country_id:, created_at:, postcode: "SW10 0AA")
    assessment_index += 1
  end
  sap_versions_epc.each do |version|
    assessment_id = "3333-0000-0000-0000-#{assessment_index.to_s.rjust(4, '0')}"
    load_sample_document(documents_gateway:, schema: version, assessment_id:, assessment_type: "SAP", sample_type: "epc", country_id:, created_at:, postcode: "SW10 0AA")
    assessment_index += 1
  end

  pp "Loading CEPC samples"

  cepc_versions = %w[CEPC-7.0 CEPC-7.1 CEPC-8.0.0]
  cepc_assessment_ids = %w[4444-5555-6666-7777-8888 9999-9999-3333-9999-3333 0000-0000-0000-0000-0000]
  cepc_versions.each_with_index do |version, index|
    assessment_id = cepc_assessment_ids[index]
    load_sample_document(documents_gateway:, schema: version, assessment_id:, assessment_type: "CEPC", sample_type: "cepc+rr", country_id:, created_at:, postcode: "SW10 0AA")
    assessment_index += 1
  end

  pp "Loading DEC samples"

  dec_assessment_ids = %w[3333-4444-5555-6666-7777 0000-0000-0000-0000-0005 0000-0000-0000-0000-0001]
  cepc_versions.each_with_index do |version, index|
    assessment_id = dec_assessment_ids[index]
    load_sample_document(documents_gateway:, schema: version, assessment_id:, assessment_type: "DEC", sample_type: "dec+rr", country_id:, created_at:, postcode: "SW10 0AA")
  end

  pp "Seed data added to database"
end

def load_sample_document(documents_gateway:, schema:, assessment_id:, assessment_type:, sample_type:, country_id: 1, created_at: nil, postcode: nil)
  sample = Samples.xml(schema, sample_type)
  use_case = UseCase::ParseXmlCertificate.new
  parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id:)
  parsed_epc["assessment_type"] = assessment_type
  parsed_epc["schema_type"] = schema
  parsed_epc["created_at"] = created_at.to_s unless created_at.nil?
  parsed_epc["postcode"] = postcode unless postcode.nil?
  documents_gateway.add_assessment(assessment_id:, document: parsed_epc)
  country_gateway = Gateway::AssessmentsCountryIdGateway.new
  country_gateway.insert(assessment_id:, country_id:) unless country_id.nil?
end
