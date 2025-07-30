require_relative "../../shared_context/shared_lodgement"

describe Domain::RedactedDocument do
  include_context "when lodging XML"

  let(:document) do
    parse_assessment(assessment_id: "9999-0000-0000-0000-9996", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", assessment_address_id: "RRN-0000-0000-0000-0000-0000", different_fields: { "postcode" => "SW10 0AA" })
  end

  let(:result) do
    { "document" =>
                      {
                        "schema_version_original" => "LIG-19.0",
                        "sap_version" => 9.94,
                        "calculation_software_name" => "Elmhurst Energy Systems RdSAP Calculator",
                        "calculation_software_version" => "4.05r0005",
                        "rrn" => "8570-6826-6530-4969-0202",
                        "inspection_date" => "2020-06-01",
                        "report_type" => 2,
                        "completion_date" => "2020-06-01",
                        "registration_date" => "2020-06-01",
                        "status" => "entered",
                        "language_code" => 1,
                        "scheme_assessor_id" => "EES/008538",
                        "tenure" => 1,
                        "transaction_type" => 1,
                        "property_type" => 0,
                        "property" =>
                          { "address" =>
                              { "address_line_1" => "25, Marlborough Place",
                                "post_town" => "LONDON",
                                "postcode" => "NW8 0PG" },
                            "uprn" => 7_435_089_668 },
                        "region_code" => 17,
                        "country_code" => "EAW",
                        "equipment_owner" =>
                          [{ "equipment_owner_name" => "Mr Joe Blobby",
                             "telephone_number" => "07855 55555555",
                             "organisation_name" => "Mr Blobby's Sports Academy",
                             "registered_address" =>
                               { "address_line_2" => "Mr Blobby's Sports Academy",
                                 "address_line_3" => "Blobby Road",
                                 "address_line_4" => "Blobby Blobby",
                                 "post_town" => "POSTTOWN",
                                 "postcode" => "PT14 5FA" } }],
                        "equipment_operator" =>
                          [{ "responsible_person" => "Operator Person",
                             "telephone_number" => 0,
                             "organisation_name" => "Organisation Plc",
                             "registered_address" => { "postcode" => "NE0 0AA" } },
                           { "responsible_person" => "Operator Person",
                             "telephone_number" => 0,
                             "organisation_name" => "Organisation Plc",
                             "registered_address" => { "postcode" => "NE0 0AA" } }],
                        "owner" => "Joe Coffee",
                        "occupier" => "Mr Blobby's Sports Academy",
                      }.to_json,
      "assessment_id" => "8570-6826-6530-4969-0202" }
  end

  let(:expected_data) do
    {
      assessment_id: "8570-6826-6530-4969-0202",
      document: {
        "schema_version_original" => "LIG-19.0",
        "sap_version" => 9.94,
        "calculation_software_name" => "Elmhurst Energy Systems RdSAP Calculator",
        "calculation_software_version" => "4.05r0005",
        "rrn" => "8570-6826-6530-4969-0202",
        "inspection_date" => "2020-06-01",
        "report_type" => 2,
        "completion_date" => "2020-06-01",
        "registration_date" => "2020-06-01",
        "status" => "entered",
        "language_code" => 1,
        "tenure" => 1,
        "transaction_type" => 1,
        "property_type" => 0,
        "property" =>
        { "address" =>
            { "address_line_1" => "25, Marlborough Place",
              "post_town" => "LONDON",
              "postcode" => "NW8 0PG" },
          "uprn" => 7_435_089_668 },
        "region_code" => 17,
        "country_code" => "EAW",
      }.to_json,
    }
  end

  let(:arguments) do
    {
      result:,
    }
  end

  let(:domain) { described_class.new(**arguments) }

  describe "#to_hash" do
    it "returns the expected hash with pii fields removed" do
      expect(domain.to_hash).to eq expected_data
    end

    context "when different certificate versions are redacted" do
      let(:redacted_keys) do
        %w[scheme_assessor_id equipment_owner equipment_operator owner occupier]
      end

      it "SAP-Schema-16.0 contains data for the relevant columns" do
        document = parse_assessment(schema_type: "SAP-Schema-16.0", assessment_id: "0000-0000-0000-0001-0160", type_of_assessment: "SAP", type: "sap")

        result = {
          "document" => document.to_json,
          "assessment_id" => "0000-0000-0000-0001-0160",
        }
        redacted = described_class.new(result:)
        redacted_result = JSON.parse(redacted.to_hash[:document])

        redacted_keys.each do |redacted_key|
          expect(redacted_result).not_to have_key(redacted_key)
        end
      end

      it "SAP-Schema-19.1.0 contains data for the relevant columns" do
        document = parse_assessment(schema_type: "SAP-Schema-19.1.0", assessment_id: "0000-0000-0000-0001-0160", type_of_assessment: "SAP", type: "epc")

        result = {
          "document" => document.to_json,
          "assessment_id" => "0000-0000-0000-0001-0160",
        }
        redacted = described_class.new(result:)
        redacted_result = JSON.parse(redacted.to_hash[:document])

        redacted_keys.each do |redacted_key|
          expect(redacted_result).not_to have_key(redacted_key)
        end
      end

      it "RdSAP-Schema-17.0 contains data for the relevant columns" do
        document = parse_assessment(schema_type: "RdSAP-Schema-17.0", assessment_id: "0000-0000-0000-0001-0160", type_of_assessment: "RdSAP", type: "epc")

        result = {
          "document" => document.to_json,
          "assessment_id" => "0000-0000-0000-0001-0160",
        }
        redacted = described_class.new(result:)
        redacted_result = JSON.parse(redacted.to_hash[:document])

        redacted_keys.each do |redacted_key|
          expect(redacted_result).not_to have_key(redacted_key)
        end
      end

      it "RdSAP-Schema-21.0.1 contains data for the relevant columns" do
        document = parse_assessment(schema_type: "RdSAP-Schema-21.0.1", assessment_id: "0000-0000-0000-0001-0160", type_of_assessment: "RdSAP", type: "epc")

        result = {
          "document" => document.to_json,
          "assessment_id" => "0000-0000-0000-0001-0160",
        }
        redacted = described_class.new(result:)
        redacted_result = JSON.parse(redacted.to_hash[:document])

        redacted_keys.each do |redacted_key|
          expect(redacted_result).not_to have_key(redacted_key)
        end
      end

      it "CEPC-7.0 contains data for the relevant columns" do
        document = parse_assessment(schema_type: "CEPC-7.0", assessment_id: "4444-5555-6666-7777-8888", type_of_assessment: "CEPC", type: "cepc+rr")

        result = {
          "document" => document.to_json,
          "assessment_id" => "4444-5555-6666-7777-8888",
        }
        redacted = described_class.new(result:)
        redacted_result = JSON.parse(redacted.to_hash[:document])

        redacted_keys.each do |redacted_key|
          expect(redacted_result).not_to have_key(redacted_key)
        end
      end

      it "CEPC-8.0.0 contains data for the relevant columns" do
        document = parse_assessment(schema_type: "CEPC-8.0.0", assessment_id: "0000-0000-0000-0000-0000", type_of_assessment: "CEPC", type: "cepc")

        result = {
          "document" => document.to_json,
          "assessment_id" => "0000-0000-0000-0000-0000",
        }
        redacted = described_class.new(result:)
        redacted_result = JSON.parse(redacted.to_hash[:document])

        redacted_keys.each do |redacted_key|
          expect(redacted_result).not_to have_key(redacted_key)
        end
      end

      it "DEC for CEPC-8.0.0 contains data for the relevant columns" do
        document = parse_assessment(schema_type: "CEPC-8.0.0", assessment_id: "0000-0000-0000-0000-0000", type_of_assessment: "DEC", type: "dec")

        result = {
          "document" => document.to_json,
          "assessment_id" => "0000-0000-0000-0000-0000",
        }
        redacted = described_class.new(result:)
        redacted_result = JSON.parse(redacted.to_hash[:document])

        redacted_keys.each do |redacted_key|
          expect(redacted_result).not_to have_key(redacted_key)
        end
      end

      it "DEC-RR for CEPC-8.0.0 contains data for the relevant columns" do
        document = parse_assessment(schema_type: "CEPC-8.0.0", assessment_id: "0000-0000-0000-0000-0000", type_of_assessment: "DEC", type: "dec-rr")

        result = {
          "document" => document.to_json,
          "assessment_id" => "0000-0000-0000-0000-0000",
        }
        redacted = described_class.new(result:)
        redacted_result = JSON.parse(redacted.to_hash[:document])

        redacted_keys.each do |redacted_key|
          expect(redacted_result).not_to have_key(redacted_key)
        end
      end
    end
  end
end
