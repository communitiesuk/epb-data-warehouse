describe Domain::RedactedDocument do
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
  end
end
