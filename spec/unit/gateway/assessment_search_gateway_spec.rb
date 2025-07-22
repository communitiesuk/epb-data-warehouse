require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"

describe Gateway::AssessmentSearchGateway do
  subject(:gateway) { described_class.new }

  include_context "when lodging XML"
  include_context "when saving ons data"

  let(:search) do
    ActiveRecord::Base.connection.exec_query(
      "SELECT * FROM assessment_search",
    )
  end

  let(:event_type) { "cancelled" }
  let(:assessment_id) { "0000-0000-0001-1234-0000" }
  let(:country_id) { 1 }
  let(:rdsap) do
    parse_assessment(assessment_id: "9999-0000-0000-0000-9996", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", assessment_address_id: "RRN-0000-0000-0000-0000-0000", different_fields: { "postcode" => "SW10 0AA" })
  end

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
  end

  describe "#insert_assessment" do
    before do
      Timecop.freeze(Time.utc(2025, 7, 4, 12, 0))
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_search;")
    end

    after do
      Timecop.return
    end

    context "when saving a domestic EPC" do
      before do
        gateway.insert_assessment(assessment_id:, document: rdsap, country_id:)
      end

      it "saves the row to the table" do
        expect(search.length).to eq 1
        expect(search.first["assessment_id"]).to eq assessment_id
      end

      it "calculates and stores the right energy band" do
        expect(search.first["current_energy_efficiency_band"]).to eq "E"
      end

      it "produces the correct address" do
        expect(search.first["address"]).to eq "1 some street whitbury"
      end

      it "contains all expected data" do
        expected_rdsap = {
          "assessment_id" => "0000-0000-0001-1234-0000",
          "address_line_1" => "1 Some Street",
          "address_line_2" => nil,
          "address_line_3" => nil,
          "address_line_4" => nil,
          "post_town" => "Whitbury",
          "postcode" => "SW10 0AA",
          "current_energy_efficiency_rating" => 50,
          "current_energy_efficiency_band" => "E",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "assessment_address_id" => "RRN-0000-0000-0000-0000-0000",
          "address" => "1 some street whitbury",
          "registration_date" => Time.parse("2020-05-04 00:00:00.000000000 +0000"),
          "assessment_type" => "RdSAP",
          "created_at" => Time.now,
        }

        expect(search.first).to eq expected_rdsap
      end
    end

    context "when saving a CEPC" do
      let(:cepc_document) do
        parse_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", assessment_address_id: "RRN-0000-0000-0000-0000-0001", type: "cepc", different_fields: { "postcode" => "W6 9ZD" })
      end

      before do
        gateway.insert_assessment(assessment_id: "0000-0000-0001-1234-0001", document: cepc_document, country_id:)
      end

      it "contains all the expected data" do
        expected_data = {
          "assessment_id" => "0000-0000-0001-1234-0001",
          "address_line_1" => "60 Maple Syrup Road",
          "address_line_2" => "Candy Mountain",
          "address_line_3" => nil,
          "address_line_4" => nil,
          "post_town" => "Big Rock",
          "postcode" => "W6 9ZD",
          "current_energy_efficiency_rating" => 84,
          "current_energy_efficiency_band" => "D",
          "council" => "Hammersmith and Fulham",
          "constituency" => "Chelsea and Fulham",
          "assessment_address_id" => "RRN-0000-0000-0000-0000-0001",
          "address" => "60 maple syrup road candy mountain big rock",
          "registration_date" => Time.parse("2021-03-19 00:00:00 UTC"),
          "assessment_type" => "CEPC",
          "created_at" => Time.now,
        }

        expect(search.first).to eq expected_data
      end

      context "when the asset rating is nil" do
        let(:assessment_id) { "0000-0000-0000-0000-0001" }
        let(:cepc) do
          parse_assessment(assessment_id:, schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", assessment_address_id: "RRN-0000-0000-0000-0000-0001", type: "cepc", different_fields: { "postcode" => "W6 9ZD", "asset_rating" => nil })
        end

        before do
          gateway.insert_assessment(assessment_id:, document: cepc, country_id:)
        end

        it "the current energy rating is 0" do
          row = search.find { |x| x["assessment_id"] == assessment_id }
          expect(row["assessment_id"]).to eq assessment_id
          expect(row["current_energy_efficiency_rating"]).to eq 0
          expect(row["current_energy_efficiency_band"]).to be_nil
        end
      end

      context "when the asset rating is A+" do
        let(:assessment_id) { "0000-0000-0000-0000-0001" }
        let(:cepc) do
          parse_assessment(assessment_id:, schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", assessment_address_id: "RRN-0000-0000-0000-0000-0001", type: "cepc", different_fields: { "postcode" => "W6 9ZD", "asset_rating" => -1 })
        end

        before do
          gateway.insert_assessment(assessment_id:, document: cepc, country_id:)
        end

        it "the current energy rating is 0" do
          row = search.find { |x| x["assessment_id"] == assessment_id }
          expect(row["assessment_id"]).to eq assessment_id
          expect(row["current_energy_efficiency_rating"]).to eq(-1)
          expect(row["current_energy_efficiency_band"]).to eq "A+"
        end
      end
    end

    context "when saving a DEC" do
      let(:dec) do
        parse_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type: "CEPC-8.0.0", type_of_assessment: "DEC", assessment_address_id: "RRN-0000-0000-0000-0000-0001", type: "dec", different_fields: { "postcode" => "W6 9ZD" })
      end

      before do
        gateway.insert_assessment(assessment_id: "0000-0000-0001-1234-0001", document: dec, country_id:)
      end

      it "contains all the expected data" do
        expected_data = {
          "assessment_id" => "0000-0000-0001-1234-0001",
          "address_line_1" => "Some Unit",
          "address_line_2" => "2 Lonely Street",
          "address_line_3" => "Some Area",
          "address_line_4" => "Some County",
          "post_town" => "Whitbury",
          "postcode" => "W6 9ZD",
          "current_energy_efficiency_band" => "A",
          "current_energy_efficiency_rating" => 1,
          "council" => "Hammersmith and Fulham",
          "constituency" => "Chelsea and Fulham",
          "assessment_address_id" => "RRN-0000-0000-0000-0000-0001",
          "address" => "some unit 2 lonely street some area some county whitbury",
          "registration_date" => Time.parse("2020-05-04 00:00:00 UTC"),
          "assessment_type" => "DEC",
          "created_at" => Time.now,
        }

        expect(search.first).to eq expected_data
      end
    end

    context "when saving a DEC-RR" do
      let(:dec) do
        parse_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type: "CEPC-8.0.0", type_of_assessment: "DEC-RR", assessment_address_id: "RRN-0000-0000-0000-0000-0001", type: "dec-rr", different_fields: { "postcode" => "W6 9ZD" })
      end

      before do
        gateway.insert_assessment(assessment_id: "0000-0000-0001-1234-0001", document: dec, country_id:)
      end

      it "contains all the expected data" do
        expected_data = {
          "assessment_id" => "0000-0000-0001-1234-0001",
          "address_line_1" => "Some Unit",
          "address_line_2" => "2 Lonely Street",
          "address_line_3" => "Some Area",
          "address_line_4" => "Some County",
          "post_town" => "Fulchester",
          "postcode" => "W6 9ZD",
          "current_energy_efficiency_rating" => 0,
          "current_energy_efficiency_band" => nil,
          "council" => "Hammersmith and Fulham",
          "constituency" => "Chelsea and Fulham",
          "assessment_address_id" => "RRN-0000-0000-0000-0000-0001",
          "address" => "some unit 2 lonely street some area some county fulchester",
          "registration_date" => Time.parse("2020-05-04 00:00:00 UTC"),
          "assessment_type" => "DEC-RR",
          "created_at" => Time.now,
        }

        expect(search.first).to eq expected_data
      end
    end

    context "when saving a SAP" do
      let(:sap) do
        parse_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type: "SAP-Schema-19.0.0", type_of_assessment: "SAP", assessment_address_id: "RRN-0000-0000-0000-0000-0001", type: "epc", different_fields: { "postcode" => "ML9 9AR" })
      end

      before do
        gateway.insert_assessment(assessment_id: "0000-0000-0001-1234-0001", document: sap, country_id:)
      end

      it "contains all the expected data" do
        expected_data = {
          "assessment_id" => "0000-0000-0001-1234-0001",
          "address_line_1" => "1 Some Street",
          "address_line_2" => "Some Area",
          "address_line_3" => "Some County",
          "address_line_4" => nil,
          "post_town" => "Whitbury",
          "postcode" => "ML9 9AR",
          "current_energy_efficiency_rating" => 72,
          "current_energy_efficiency_band" => "C",
          "constituency" => "Lanark and Hamilton East",
          "council" => "South Lanarkshire",
          "assessment_address_id" => "RRN-0000-0000-0000-0000-0001",
          "address" => "1 some street some area some county whitbury",
          "registration_date" => Time.parse("2022-05-09 00:00:00 UTC"),
          "assessment_type" => "SAP",
          "created_at" => Time.now,
        }

        expect(search.first).to eq expected_data
      end
    end

    context "when the EPC has a nil address line" do
      let(:document) do
        rdsap.merge({ "address_line_1" => nil })
      end

      it "does not raise an error" do
        expect { gateway.insert_assessment(assessment_id:, document:, country_id:) }.not_to raise_error
      end

      it "produces a valid address value" do
        gateway.insert_assessment(assessment_id:, document:, country_id:)
        expect(search.length).to eq 1
        expect(search.first["address"]).to eq("whitbury")
      end
    end

    context "when the same assessment_id and the same event are being saved" do
      before do
        gateway.insert_assessment(assessment_id:, document: rdsap, country_id:)
      end

      it "does not raise an error" do
        expect { gateway.insert_assessment(assessment_id:, document: rdsap, country_id:) }.not_to raise_error
      end

      it "saves only one row for the assessment" do
        gateway.insert_assessment(assessment_id:, document: rdsap, country_id:)
        expect(search.length).to eq 1
      end
    end

    context "when the different assessment_ids are being saved" do
      let(:rrns) do
        %w[0000-0000-0001-1234-0000 0000-0000-0001-1234-0001 0000-0000-0001-1234-0003]
      end

      before do
        rrns.each do |assessment_id|
          gateway.insert_assessment(assessment_id:, document: rdsap, country_id:)
        end
      end

      it "saves 3 row to the table" do
        expect(search.length).to eq 3
      end

      it "there are 3 unique assessment_ids in the table" do
        result = search.map { |row| row["assessment_id"] }
        expect(result).to eq rrns
      end
    end

    context "when the postcode can't be found in our ONS db" do
      let(:invalid_postcode) { "M4 6PP" }

      let(:document) { rdsap.merge("postcode" => invalid_postcode) }

      it "does not raise an error" do
        expect { gateway.insert_assessment(assessment_id:, document:, country_id:) }.not_to raise_error
      end

      it "saves the row with empty Council and Parliamentary Constituency" do
        gateway.insert_assessment(assessment_id:, document:, country_id:)
        expect(search.length).to eq 1
        expect(search.first["council"]).to be_nil
        expect(search.first["constituency"]).to be_nil
      end
    end

    context "when the certificate is not in England or Wales" do
      it "does not save the document in the table" do
        invalid_country_id = 3 # Northern Ireland
        gateway.insert_assessment(assessment_id:, document: rdsap, country_id: invalid_country_id)
        expect(search.length).to eq 0
      end
    end

    context "when the certificate is of an invalid type" do
      it "does not save AC-CERTs in the table" do
        invalid_document = rdsap.merge({ "assessment_type" => "AC-CERT" })
        gateway.insert_assessment(assessment_id:, document: invalid_document, country_id:)
        expect(search.length).to eq 0
      end
    end

    context "when one of the address lines is an integer" do
      let(:doc) do
        parse_assessment(assessment_id: "9999-0000-0000-0000-9997",
                         schema_type: "RdSAP-Schema-20.0.0",
                         type_of_assessment: "RdSAP",
                         assessment_address_id: "RRN-0000-0000-0000-0000-0000", different_fields: { "address_line_1" => 14 })
      end

      before do
        gateway.insert_assessment(assessment_id: "9999-0000-0000-0000-9997", document: doc, country_id:)
      end

      it "produces the correct address" do
        epc = search.find { |i| i["assessment_id"] == "9999-0000-0000-0000-9997" }
        expect(epc["address"]).to eq "14 whitbury"
      end
    end
  end

  describe "#update_attribute" do
    before do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_search;")
      gateway.insert_assessment(assessment_id: "9999-0000-0000-0011-9996", document: rdsap, country_id:)
    end

    it "updates the assessment search attribute" do
      gateway.update_attribute(assessment_id: "9999-0000-0000-0011-9996", attribute_name: "assessment_address_id", new_value: "RRN-0000-0000-0000-0000-0011")
      expect(search.first["assessment_address_id"]).to eq "RRN-0000-0000-0000-0000-0011"
    end

    context "when the assessment id is not found" do
      it "does not error" do
        expect { gateway.update_attribute(assessment_id: "9999-0000-0000-0000-1111", attribute_name: "assessment_address_id", new_value: "RRN-0000-0000-0000-0000-0011") }.not_to raise_error
      end
    end
  end

  describe "#delete_assessment" do
    before do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_search;")
      gateway.insert_assessment(assessment_id: "9999-0000-0000-0000-9996", document: rdsap, country_id:)
      gateway.insert_assessment(assessment_id: "9999-0000-0000-0000-9999", document: rdsap, country_id:)
    end

    it "deletes one of the assessments" do
      gateway.delete_assessment(assessment_id: "9999-0000-0000-0000-9996")
      expect(search.length).to eq 1
      expect(search.first["assessment_id"]).to eq "9999-0000-0000-0000-9999"
    end

    context "when the assessment id is not found" do
      it "does not error" do
        expect { gateway.delete_assessment(assessment_id: "9999-0000-0000-0000-1111") }.not_to raise_error
      end
    end
  end

  describe "#find_assesments" do
    let(:args) do
      {
        date_start: "2014-12-01",
        date_end: "2024-12-09",
        assessment_type: %w[RdSAP SAP],
      }
    end

    let(:cepc) do
      parse_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", assessment_address_id: "RRN-0000-0000-0000-0000-0001", type: "cepc", different_fields: { "postcode" => "W6 9ZD" })
    end

    before do
      Timecop.freeze(Date.yesterday.to_time.utc)
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_search;")

      2.times do |i|
        assessment_id = "0000-0000-0000-#{i.to_s.rjust(4, '0')}"
        gateway.insert_assessment(assessment_id:, document: rdsap, country_id:)
      end

      3.times do |i|
        assessment_id = "0001-0000-0000-#{i.to_s.rjust(4, '0')}"
        gateway.insert_assessment(assessment_id:, document: cepc, country_id:)
      end
      Timecop.return
    end

    it "returns the required columns" do
      expected_result = {
        "certificate_number" => "0000-0000-0000-0000",
        "address_line_1" => "1 Some Street",
        "address_line_2" => nil,
        "address_line_3" => nil,
        "address_line_4" => nil,
        "assessment_address_id" => "RRN-0000-0000-0000-0000-0000",
        "constituency" => "Chelsea and Fulham",
        "council" => "Hammersmith and Fulham",
        "current_energy_efficiency_band" => "E",
        "post_town" => "Whitbury",
        "postcode" => "SW10 0AA",
        "registration_date" => Date.new(2020, 5, 4),
      }
      expect(gateway.find_assessments(**args).first).to eq expected_result
    end

    it "returns data for domestic" do
      domestic_args = args.merge({ assessment_type: %w[RdSAP SAP] })
      expect(gateway.find_assessments(**domestic_args).length).to eq 2
    end

    context "when filtering for an address" do
      before do
        Timecop.freeze(Date.yesterday.to_time.utc)
        address_rdsap = rdsap.merge({ "address_line_1" => "2 Some street" })
        gateway.insert_assessment(assessment_id: "0000-0000-0010-0123", document: address_rdsap, country_id:)
        Timecop.return
      end

      it "returns one row for the exact address" do
        address = "2 Some street"
        address_args = args.merge({ assessment_type: %w[RdSAP SAP], address: })
        expect(gateway.find_assessments(**address_args).length).to eq 1
        expect(gateway.find_assessments(**address_args).first["address_line_1"]).to eq(address)
        expect(gateway.find_assessments(**address_args).first["certificate_number"]).to eq("0000-0000-0010-0123")
      end

      it "returns all the rows matching partial address" do
        address = "Some street"
        address_args = args.merge({ assessment_type: %w[RdSAP SAP], address: })
        expect(gateway.find_assessments(**address_args).length).to eq 3
      end

      it "returns all the rows matching partial address regardless of casing" do
        address = "SOme StrEet"
        address_args = args.merge({ assessment_type: %w[RdSAP SAP], address: })
        expect(gateway.find_assessments(**address_args).length).to eq 3
      end
    end

    context "when filtering for dates" do
      before do
        date_rdsap = rdsap.merge({ "registration_date" => "2022-02-05" })
        Timecop.freeze(Date.yesterday.to_time.utc)
        gateway.insert_assessment(assessment_id: "0000-0000-0020-0123", document: date_rdsap, country_id:)
        Timecop.return
      end

      it "returns one row for the date range" do
        date_args = args.merge({ date_start: "2021-12-01", date_end: "2024-12-09" })
        expect(gateway.find_assessments(**date_args).length).to eq 1
        expect(gateway.find_assessments(**date_args).first["certificate_number"]).to eq("0000-0000-0020-0123")
      end
    end

    context "when filtering by council" do
      before do
        postcode_rdsap = rdsap.merge({ "postcode" => "SW1A 2AA" })
        Timecop.freeze(Date.yesterday.to_time.utc)
        gateway.insert_assessment(assessment_id: "0000-0000-0022-0022", document: postcode_rdsap, country_id:)
        Timecop.return
      end

      it "returns one row for the council" do
        council_args = args.merge({ council: %w[Westminster] })
        expect(gateway.find_assessments(**council_args).length).to eq 1
        expect(gateway.find_assessments(**council_args).first["certificate_number"]).to eq("0000-0000-0022-0022")
      end

      it "returns multiple rows when searching for multiple councils" do
        council_args = args.merge({ council: ["Westminster", "Hammersmith and Fulham"] })
        expect(gateway.find_assessments(**council_args).length).to eq 3
      end
    end

    context "when having data from today" do
      before do
        gateway.insert_assessment(assessment_id: "0000-0000-0020-0123", document: rdsap, country_id:)
      end

      it "ignores the assessment created today" do
        expect(gateway.find_assessments(**args).length).to eq 2
      end
    end
  end
end
