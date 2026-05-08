shared_context "when saving EPCs" do
  def save_epc(schema:, assessment_id:, type:, stub: nil, country_id: 1, registration_date: nil)
    if stub.nil?
      sample = Samples.xml(schema)
      use_case = UseCase::ParseXmlCertificate.new
      parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id:)
    else
      parsed_epc = stub
    end
    parsed_epc["assessment_type"] = type
    parsed_epc["schema_type"] = schema
    parsed_epc["registration_date"] = registration_date.to_s if registration_date
    import = UseCase::ImportCertificateData.new(
      assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new,
      documents_gateway: Gateway::DocumentsGateway.new,
      assessment_search_gateway: Gateway::AssessmentSearchGateway.new,
      commercial_reports_gateway: Gateway::CommercialReportsGateway.new,
    )
    import.execute(assessment_id:, certificate_data: parsed_epc, country_id:)
  end
end
