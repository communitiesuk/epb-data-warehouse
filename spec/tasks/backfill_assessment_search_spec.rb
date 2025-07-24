shared_context "when inserting epc documents" do
  def save_new_epc(schema:, assessment_id:, assessment_type:, sample_type:, country_id: 1, created_at: nil, postcode: nil)
    sample = Samples.xml(schema, sample_type)
    use_case = UseCase::ParseXmlCertificate.new
    parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id:)
    parsed_epc["assessment_type"] = assessment_type
    parsed_epc["schema_type"] = schema
    parsed_epc["created_at"] = created_at.to_s unless created_at.nil?
    parsed_epc["registration_date"] = created_at.to_s unless created_at.nil?
    parsed_epc["postcode"] = postcode unless postcode.nil?
    import = Gateway::DocumentsGateway.new
    import.add_assessment(assessment_id:, document: parsed_epc)
    country_gateway = Gateway::AssessmentsCountryIdGateway.new
    country_gateway.insert(assessment_id:, country_id:) unless country_id.nil?
  end
end

require_relative "../shared_context/shared_lodgement"
describe "Backfill assessment_search table rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:backfill_assessment_search") }

    include_context "when inserting epc documents"
    after do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_attribute_values;")
    end

    let(:search) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_search",
      )
    end

    before do
      allow($stdout).to receive(:puts)
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

      it "shows a message of the assessments count to be backfilled" do
        expect { task.invoke }.to output(/Total assessments to back fill: 3/).to_stdout
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
        expect { task.invoke }.to output(/Total assessments to back fill: 0/).to_stdout
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
        created_at = Date.new(2025, 7, 14)
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-3333", assessment_type: "RdSAP", sample_type: "epc", created_at:)
        task.invoke

        epc = search.find { |i| i["assessment_id"] == "0000-6666-4444-3333-3333" }
        expect(epc["created_at"]).to eq "2025-07-14"
      end

      it "uses the registration_date when created_at is not available" do
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-8888", assessment_type: "RdSAP", sample_type: "epc")
        task.invoke
        epc = search.find { |i| i["assessment_id"] == "0000-6666-4444-3333-8888" }
        expect(epc["created_at"]).to eq "2020-06-04"
      end
    end

    context "when dates are set using environment variables" do
      before do
        ENV["START_DATE"] = "2023-01-01"
        ENV["END_DATE"] = "2023-12-31"
      end

      after do
        ENV.delete("START_DATE")
        ENV.delete("END_DATE")
      end

      it "only saves the ones with a 'created_at' value inside the date range" do
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-3322", assessment_type: "RdSAP", sample_type: "epc", created_at: Date.new(2022, 7, 14))
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-3333", assessment_type: "RdSAP", sample_type: "epc", created_at: Date.new(2023, 7, 14))
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-3344", assessment_type: "RdSAP", sample_type: "epc", created_at: Date.new(2024, 7, 14))
        task.invoke
        expect(search.length).to eq(1)
        expect(search.first["assessment_id"]).to eq("0000-6666-4444-3333-3333")
      end
    end

    context "when different certificate versions are saved" do
      let(:created_at) do
        Date.new(2025, 7, 14)
      end
      let(:columns_to_check) do
        %w[assessment_id address_line_1 post_town postcode current_energy_efficiency_rating current_energy_efficiency_band council constituency address registration_date assessment_type created_at]
      end

      before do
        ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_documents;")
      end

      it "SAP-Schema-16.0 contains data for the relevant columns" do
        save_new_epc(schema: "SAP-Schema-16.0", assessment_id: "0000-0000-0000-0001-0160", assessment_type: "SAP", sample_type: "sap", created_at:, postcode: "SW10 0AA")
        task.invoke
        expect(search.length).to eq(1)
        expected_result = {
          "address" => "28, place drive town",
          "address_line_1" => "28, Place Drive",
          "address_line_2" => nil,
          "address_line_3" => nil,
          "address_line_4" => nil,
          "assessment_address_id" => nil,
          "assessment_id" => "0000-0000-0000-0001-0160",
          "assessment_type" => "SAP",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "created_at" => Date.new(2025, 7, 14),
          "current_energy_efficiency_band" => "B",
          "current_energy_efficiency_rating" => 82,
          "post_town" => "Town",
          "postcode" => "SW10 0AA",
          "registration_date" => Date.new(2025, 7, 14),
        }
        expect(search.first).to eq(expected_result)
      end

      it "SAP-Schema-19.1.0 contains data for the relevant columns" do
        save_new_epc(schema: "SAP-Schema-19.1.0", assessment_id: "0000-0000-0000-0001-0191", assessment_type: "SAP", sample_type: "epc", created_at:, postcode: "SW10 0AA")
        task.invoke
        expect(search.length).to eq(1)
        expected_result = {
          "address" => "1 some street some area some county whitbury",
          "address_line_1" => "1 Some Street",
          "address_line_2" => "Some Area",
          "address_line_3" => "Some County",
          "address_line_4" => nil,
          "assessment_address_id" => nil,
          "assessment_id" => "0000-0000-0000-0001-0191",
          "assessment_type" => "SAP",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "created_at" => Date.new(2025, 7, 14),
          "current_energy_efficiency_band" => "C",
          "current_energy_efficiency_rating" => 72,
          "post_town" => "Whitbury",
          "postcode" => "SW10 0AA",
          "registration_date" => Date.new(2025, 7, 14),
        }
        expect(search.first).to eq(expected_result)
      end

      it "RdSAP-Schema-17.0 contains data for the relevant columns" do
        save_new_epc(schema: "RdSAP-Schema-17.0", assessment_id: "0000-0000-0000-0002-0170", assessment_type: "RdSAP", sample_type: "epc", created_at:, postcode: "SW10 0AA")
        task.invoke
        expect(search.length).to eq(1)
        expected_result = {
          "address" => "42, moria mines lane posttown",
          "address_line_1" => "42, Moria Mines Lane",
          "address_line_2" => nil,
          "address_line_3" => nil,
          "address_line_4" => nil,
          "assessment_address_id" => nil,
          "assessment_id" => "0000-0000-0000-0002-0170",
          "assessment_type" => "RdSAP",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "created_at" => Date.new(2025, 7, 14),
          "current_energy_efficiency_band" => "D",
          "current_energy_efficiency_rating" => 66,
          "post_town" => "POSTTOWN",
          "postcode" => "SW10 0AA",
          "registration_date" => Date.new(2025, 7, 14),
        }
        expect(search.first).to eq(expected_result)
      end

      it "RdSAP-Schema-21.0.1 contains data for the relevant columns" do
        save_new_epc(schema: "RdSAP-Schema-21.0.1", assessment_id: "0000-0000-0000-0002-2101", assessment_type: "RdSAP", sample_type: "epc", created_at:, postcode: "SW10 0AA")
        task.invoke
        expect(search.length).to eq(1)
        expected_result = {
          "address" => "1 some street whitbury",
          "address_line_1" => "1 Some Street",
          "address_line_2" => nil,
          "address_line_3" => nil,
          "address_line_4" => nil,
          "assessment_address_id" => nil,
          "assessment_id" => "0000-0000-0000-0002-2101",
          "assessment_type" => "RdSAP",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "created_at" => Date.new(2025, 7, 14),
          "current_energy_efficiency_band" => "E",
          "current_energy_efficiency_rating" => 50,
          "post_town" => "Whitbury",
          "postcode" => "SW10 0AA",
          "registration_date" => Date.new(2025, 7, 14),
        }
        expect(search.first).to eq(expected_result)
      end

      it "CEPC-7.0 contains data for the relevant columns" do
        save_new_epc(schema: "CEPC-7.0", assessment_id: "4444-5555-6666-7777-8888", assessment_type: "CEPC", sample_type: "cepc+rr", created_at:, postcode: "SW10 0AA")
        task.invoke
        expect(search.length).to eq(1)
        expected_result = {
          "address" => "acme coffee 13 old street posttown",
          "address_line_1" => nil,
          "address_line_2" => "Acme Coffee",
          "address_line_3" => "13 Old Street",
          "address_line_4" => nil,
          "assessment_address_id" => nil,
          "assessment_id" => "4444-5555-6666-7777-8888",
          "assessment_type" => "CEPC",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "created_at" => Date.new(2025, 7, 14),
          "current_energy_efficiency_band" => "F",
          "current_energy_efficiency_rating" => 134,
          "post_town" => "POSTTOWN",
          "postcode" => "SW10 0AA",
          "registration_date" => Date.new(2025, 7, 14),
        }
        expect(search.first).to eq(expected_result)
      end

      it "CEPC-8.0.0 contains data for the relevant columns" do
        save_new_epc(schema: "CEPC-8.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "CEPC", sample_type: "cepc", created_at:, postcode: "SW10 0AA")
        task.invoke
        expect(search.length).to eq(1)
        expected_result = {
          "address" => "60 maple syrup road candy mountain big rock",
          "address_line_1" => "60 Maple Syrup Road",
          "address_line_2" => "Candy Mountain",
          "address_line_3" => nil,
          "address_line_4" => nil,
          "assessment_address_id" => nil,
          "assessment_id" => "0000-0000-0000-0000-0000",
          "assessment_type" => "CEPC",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "created_at" => Date.new(2025, 7, 14),
          "current_energy_efficiency_band" => "D",
          "current_energy_efficiency_rating" => 84,
          "post_town" => "Big Rock",
          "postcode" => "SW10 0AA",
          "registration_date" => Date.new(2025, 7, 14),
        }
        expect(search.first).to eq(expected_result)
      end

      it "DEC for CEPC-7.0 contains data for the relevant columns" do
        save_new_epc(schema: "CEPC-7.0", assessment_id: "3333-4444-5555-6666-7777", assessment_type: "DEC", sample_type: "dec+rr", created_at:, postcode: "SW10 0AA")
        task.invoke
        expect(search.length).to eq(1)
        expected_result = {
          "address" => "mr blobby's sports academy mr blobby's academy blobby custard lane posttown",
          "address_line_1" => "Mr Blobby's Sports Academy",
          "address_line_2" => "Mr Blobby's Academy",
          "address_line_3" => "Blobby Custard Lane",
          "address_line_4" => nil,
          "assessment_address_id" => nil,
          "assessment_id" => "3333-4444-5555-6666-7777",
          "assessment_type" => "DEC",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "created_at" => Date.new(2025, 7, 14),
          "current_energy_efficiency_band" => "D",
          "current_energy_efficiency_rating" => 77,
          "post_town" => "POSTTOWN",
          "postcode" => "SW10 0AA",
          "registration_date" => Date.new(2025, 7, 14),
        }
        expect(search.first).to eq(expected_result)
      end

      it "DEC for CEPC-8.0.0 contains data for the relevant columns" do
        save_new_epc(schema: "CEPC-8.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "DEC", sample_type: "dec", created_at:, postcode: "SW10 0AA")
        task.invoke
        expect(search.length).to eq(1)
        expected_result = {
          "address" => "some unit 2 lonely street some area some county whitbury",
          "address_line_1" => "Some Unit",
          "address_line_2" => "2 Lonely Street",
          "address_line_3" => "Some Area",
          "address_line_4" => "Some County",
          "assessment_address_id" => nil,
          "assessment_id" => "0000-0000-0000-0000-0000",
          "assessment_type" => "DEC",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "created_at" => Date.new(2025, 7, 14),
          "current_energy_efficiency_band" => "A",
          "current_energy_efficiency_rating" => 1,
          "post_town" => "Whitbury",
          "postcode" => "SW10 0AA",
          "registration_date" => Date.new(2025, 7, 14),
        }
        expect(search.first).to eq(expected_result)
      end

      it "DEC-RR for CEPC-8.0.0 contains data for the relevant columns" do
        save_new_epc(schema: "CEPC-8.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "DEC", sample_type: "dec-rr", created_at:, postcode: "SW10 0AA")
        task.invoke
        expect(search.length).to eq(1)
        expected_result = {
          "address" => "some unit 2 lonely street some area some county fulchester",
          "address_line_1" => "Some Unit",
          "address_line_2" => "2 Lonely Street",
          "address_line_3" => "Some Area",
          "address_line_4" => "Some County",
          "assessment_address_id" => nil,
          "assessment_id" => "0000-0000-0000-0000-0000",
          "assessment_type" => "DEC",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "created_at" => Date.new(2025, 7, 14),
          "current_energy_efficiency_band" => nil,
          "current_energy_efficiency_rating" => 0,
          "post_town" => "Fulchester",
          "postcode" => "SW10 0AA",
          "registration_date" => Date.new(2025, 7, 14),
        }
        expect(search.first).to eq(expected_result)
      end
    end

    context "when a document is not found" do
      include_context "when lodging XML"

      let(:rdsap) do
        parse_assessment(assessment_id: "0000-0000-0000-0000-0000 ", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", assessment_address_id: "RRN-0000-0000-0000-0000-0000", different_fields: { "postcode" => "SW10 0AA" })
      end

      before do
        allow(Helper::BackFillTask).to receive(:document).and_return rdsap
        allow(Helper::BackFillTask).to receive(:document).with("5555-5555-5555-5555-5555").and_raise NoMethodError
        save_new_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "SAP", sample_type: "epc")
        save_new_epc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", assessment_type: "SAP", sample_type: "epc")
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", assessment_type: "RdSAP", sample_type: "epc")
      end

      it "does not raise an error" do
        expect { task.invoke }.not_to raise_error
        expect(search.length).to be > 1
      end

      it "inserts the 2 epcs that exist" do
        task.invoke
        expect(search.length).to eq 2
      end
    end
  end
end
