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
        task.reenable
        expect{ task.invoke }.to_not raise_error
      end

      it "inserting an already existing assessment does not call the assessment search gateway" do

        task.invoke

        gateway_instance = instance_double(Gateway::AssessmentSearchGateway)
        allow(gateway_instance).to receive(:insert_assessment)
        allow(Gateway::AssessmentSearchGateway).to receive(:new).and_return(gateway_instance)

        task.reenable
        task.invoke
        expect(gateway_instance).to have_received(:insert_assessment).exactly(0).times
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

      it "uses the created_at value when available" do
        created_at = Time.utc(2025, 7, 14)
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-3333", assessment_type: "RdSAP", sample_type: "epc", created_at: )
        task.invoke

        epc = search.find { |i| i["assessment_id"] == "0000-6666-4444-3333-3333" }
        expect(epc["created_at"]).to eq "2025-07-14 00:00:00.000000"
      end

      it "uses the warehouse_created_at value when created_at is nil" do
        Timecop.freeze(Time.utc(2020, 7, 14))
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-6666", assessment_type: "RdSAP", sample_type: "epc")
        Timecop.return
        task.invoke
        epc = search.find { |i| i["assessment_id"] == "0000-6666-4444-3333-6666" }
        expect(epc["created_at"]).to eq "2020-07-14 00:00:00.000000"

      end
    end
  end

  def save_new_epc(schema:, assessment_id:, assessment_type:, sample_type:, country_id: 1, created_at: nil)
    sample = Samples.xml(schema, sample_type)
    use_case = UseCase::ParseXmlCertificate.new
    parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id:)
    parsed_epc["assessment_type"] = assessment_type
    parsed_epc["schema_type"] = schema
    parsed_epc["created_at"] = created_at.to_s unless created_at.nil?
    import = UseCase::ImportCertificateData.new(assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, documents_gateway: Gateway::DocumentsGateway.new, assessment_search_gateway: Gateway::AssessmentSearchGateway.new)
    import.execute(assessment_id:, certificate_data: parsed_epc)
    country_gateway = Gateway::AssessmentsCountryIdGateway.new
    country_gateway.insert(assessment_id:, country_id:) unless country_id.nil?
  end
end
