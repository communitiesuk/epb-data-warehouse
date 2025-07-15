describe "Backfill assessment_search table rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:backfill_assessment_search") }

    after do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_attribute_values;")
    end

    let(:search) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_search",
      )
    end

    before do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_search;")
    end

    context "when certificates have been saved" do
      before do
        save_new_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "SAP", sample_type: "epc")
        save_new_epc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", assessment_type: "SAP", sample_type: "epc")
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", assessment_type: "RdSAP", sample_type: "epc")
      end

      it "EPCs are saved into assessment search table" do
        task.invoke
        expect(search.length).to eq(3)
      end

      it "inserting an already existing assessment does not raise an error" do
        task.invoke
        task.reenable
        expect { task.invoke }.not_to raise_error
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
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-3333", assessment_type: "RdSAP", sample_type: "epc", created_at:)
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

    context "when different certificate versions are saved" do
      let(:created_at) do
        Time.utc(2025, 7, 14)
      end
      let(:columns_to_check) do
        %w[assessment_id address_line_1 post_town postcode current_energy_efficiency_rating current_energy_efficiency_band council constituency address registration_date assessment_type created_at]
      end

      before do
        ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_documents;")
      end

      it "SAP-Schema-16.0 contains data for the relevant columns" do
        save_new_epc(schema: "SAP-Schema-16.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "SAP", sample_type: "sap", created_at:, postcode: "SW10 0AA")
        task.invoke
        expect(search.length).to eq(1)
        expected_result = {
          "address" => "28, place drive town",
          "address_line_1" => "28, Place Drive",
          "address_line_2" => nil,
          "address_line_3" => nil,
          "address_line_4" => nil,
          "assessment_address_id" => nil,
          "assessment_id" => "0000-0000-0000-0000-0000",
          "assessment_type" => "SAP",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "created_at" => Time.new("2025-07-14 00:00:00.000000000 +0000"),
          "current_energy_efficiency_band" => "B",
          "current_energy_efficiency_rating" => 82,
          "post_town" => "Town",
          "postcode" => "SW10 0AA",
          "registration_date" => Time.new("2012-09-29 00:00:00.000000000 +0000"),
        }
        expect(search.first).to eq(expected_result)
      end

      it "RdSAPs do not have nil values on the relevant columns" do
        rdsap_versions = %w[RdSAP-Schema-17.0 RdSAP-Schema-17.1 RdSAP-Schema-18.0 RdSAP-Schema-19.0 RdSAP-Schema-20.0.0 RdSAP-Schema-21.0.0 RdSAP-Schema-21.0.1]

        assessment_ids = []
        rdsap_versions.each_with_index do |version, index|
          assessment_id = "0000-0000-0000-0000-#{index.to_s.rjust(4, '0')}"
          save_new_epc(schema: version, assessment_id:, assessment_type: "RdSAP", sample_type: "epc", created_at:, postcode: "SW10 0AA")
          assessment_ids << assessment_id
        end
        task.invoke

        assessment_ids.each do |assessment_id|
          row = search.find { |i| i["assessment_id"] == assessment_id }
          columns_to_check.each do |column|
            expect(row[column]).not_to be_nil
          end
        end
      end

      it "SAPs do not have nil values on the relevant columns" do
        sap_versions_sap = %w[SAP-Schema-15.0 SAP-Schema-16.0 SAP-Schema-16.1 SAP-Schema-16.2 SAP-Schema-16.3]
        sap_versions_epc = %w[SAP-Schema-17.0 SAP-Schema-17.1 SAP-Schema-18.0.0 SAP-Schema-19.0.0 SAP-Schema-19.1.0]

        assessment_ids = []
        current_assessment_id = 0
        sap_versions_sap.each do |version|
          assessment_id = "0000-0000-0000-0000-#{current_assessment_id.to_s.rjust(4, '0')}"
          current_assessment_id += 1
          save_new_epc(schema: version, assessment_id:, assessment_type: "SAP", sample_type: "sap", created_at:, postcode: "SW10 0AA")
          assessment_ids << assessment_id
        end
        sap_versions_epc.each do |version|
          assessment_id = "0000-0000-0000-0000-#{current_assessment_id.to_s.rjust(4, '0')}"
          current_assessment_id += 1
          save_new_epc(schema: version, assessment_id:, assessment_type: "SAP", sample_type: "epc", created_at:, postcode: "SW10 0AA")
          assessment_ids << assessment_id
        end
        task.invoke

        assessment_ids.each do |assessment_id|
          row = search.find { |i| i["assessment_id"] == assessment_id }
          columns_to_check.each do |column|
            expect(row[column]).not_to be_nil
          end
        end
        expect(task.invoke).to eq(2)
      end
    end
  end

  def save_new_epc(schema:, assessment_id:, assessment_type:, sample_type:, country_id: 1, created_at: nil, postcode: nil)
    sample = Samples.xml(schema, sample_type)
    use_case = UseCase::ParseXmlCertificate.new
    parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id:)
    parsed_epc["assessment_type"] = assessment_type
    parsed_epc["schema_type"] = schema
    parsed_epc["created_at"] = created_at.to_s unless created_at.nil?
    parsed_epc["postcode"] = postcode unless postcode.nil?
    import = UseCase::ImportCertificateData.new(assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, documents_gateway: Gateway::DocumentsGateway.new, assessment_search_gateway: Gateway::AssessmentSearchGateway.new)
    import.execute(assessment_id:, certificate_data: parsed_epc)
    country_gateway = Gateway::AssessmentsCountryIdGateway.new
    country_gateway.insert(assessment_id:, country_id:) unless country_id.nil?
  end
end
