shared_context "when lodging XML" do
  def add_assessment(assessment_id:, schema_type:, type_of_assessment:, type: "epc", assessment_address_id: "RRN-0000-0000-0000-0000-0000", different_fields: nil, add_heat_pump_data: true)
    meta_data_sample = {
      "assessment_type" => type_of_assessment,
      "opt_out" => false,
      "created_at" => "2021-07-21T11:26:28.045Z",
      "schema_type" => schema_type,
      "assessment_address_id" => assessment_address_id,
    }
    xml = Samples.xml(schema_type, type)

    document = UseCase::ParseXmlCertificate.new.execute(xml:, schema_type:, assessment_id:)

    add_heat_pump_data(document) if add_heat_pump_data
    document.merge!(different_fields) unless different_fields.nil?
    document.merge!(meta_data_sample)
    Gateway::DocumentsGateway.new.add_assessment(assessment_id:, document:)
  end

  def add_heat_pump_data(document)
    document.merge!(
      { "transaction_type": 6,
        "main_heating":
          [{
            "description": "Ground source heat pump, underfloor, electric",
            "energy_efficiency_rating": 5,
            "environmental_efficiency_rating": 5,
          }] },
    )
  end
end
