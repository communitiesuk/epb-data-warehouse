describe "Adding or updating hashed assessment id node rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:backfill_assessment_search") }

    before do
      save_new_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "SAP", sample_type: "epc")
      save_new_epc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", assessment_type: "SAP", sample_type: "epc")
      save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", assessment_type: "RdSAP", sample_type: "epc")

      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_search;")
    end

    after do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_attribute_values;")
    end

    let(:search) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_search",
        )
    end

    context "When certificates have been saved" do
      it "EPCs are saved into assessment search table" do
        task.invoke

        expect(search.length).to eq(3)
      end

      it "inserting an already existing assessment does not raise an error" do
        task.invoke

        expect{ task.invoke }.to_not raise_error
      end

      it "EPCs that have been opted out are not saved" do
        attribute_values_gateway = Gateway::AssessmentAttributesGateway.new
        attribute_values_gateway.add_attribute_value(assessment_id: "0000-6666-4444-3333-2222", attribute_value: "true", attribute_name: "opt_out")

        task.invoke

        expect(search.length).to eq(2)
      end

      it "doesn't save AC-CERT assessment types" do
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-1111", assessment_type: "AC-CERT", sample_type: "epc")

        task.invoke

        expect(search.length).to eq(3)
      end

      it "only saves assessments from England, Wales or England and Wales" do
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-0000", assessment_type: "SAP", sample_type: "epc", country_id: 3)

        task.invoke

        expect(search.length).to eq(3)
      end
    end
  end

  def save_new_epc(schema:, assessment_id:, assessment_type:, sample_type:, country_id: 1)
    sample = Samples.xml(schema, sample_type)
    use_case = UseCase::ParseXmlCertificate.new
    parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id:)
    parsed_epc["assessment_type"] = assessment_type
    parsed_epc["schema_type"] = schema
    import = UseCase::ImportCertificateData.new(assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, documents_gateway: Gateway::DocumentsGateway.new, assessment_search_gateway: Gateway::AssessmentSearchGateway.new)
    import.execute(assessment_id:, certificate_data: parsed_epc)
    country_gateway = Gateway::AssessmentsCountryIdGateway.new
    country_gateway.insert(assessment_id:, country_id:) unless country_id.nil?
  end
end
