describe Gateway::DocumentsGateway, :set_with_timecop do
  subject(:gateway) { described_class.new }

  let(:assessment_data) do
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
      "tenure" => 1,
      "transaction_type" => 1,
      "property_type" => 0,
      "scheme_assessor_id" => "EES/008538",
      "property" =>
        { "address" =>
            { "address_line_1" => "25, Marlborough Place",
              "post_town" => "LONDON",
              "postcode" => "NW8 0PG" },
          "uprn" => 7_435_089_668 },
      "region_code" => 17,
      "country_code" => "EAW",
    }
  end

  let(:updated_assessment_data) do
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
      "tenure" => 3, # updated value
      "transaction_type" => 1,
      "property_type" => 0,
      "scheme_assessor_id" => "EES/008538",
      "property" =>
        { "address" =>
            { "address_line_1" => "25, Marlborough Place",
              "post_town" => "LONDON",
              "postcode" => "NW8 0PG" },
          "uprn" => 7_435_089_668 },
      "region_code" => 17,
      "country_code" => "EAW",
    }
  end

  let(:assessment_id) { "8570-6826-6530-4969-0202" }

  let(:document) do
    JSON.parse(ActiveRecord::Base.connection.exec_query("SELECT * FROM assessment_documents WHERE assessment_id='#{assessment_id}'").first["document"])
  end

  let(:country_code) do
    ActiveRecord::Base.connection.exec_query("SELECT document ->>'country_code' AS country_code FROM assessment_documents WHERE assessment_id='#{assessment_id}'").first["country_code"]
  end

  let(:tenure) do
    ActiveRecord::Base.connection.exec_query("SELECT document ->>'tenure' AS tenure FROM assessment_documents WHERE assessment_id='#{assessment_id}'").first["tenure"]
  end

  before do
    ActiveRecord::Base.connection.reset_pk_sequence!("assessment_documents")
  end

  context "when adding a new record to the documents table" do
    before do
      gateway.add_assessment(assessment_id:, document: assessment_data)
    end

    it "adds it in a way that can be read back out as a whole hash" do
      expect(document).to eq assessment_data
    end

    it "adds it in a way that can be queried on using jsonb syntax" do
      expect(country_code).to eq "EAW"
    end
  end

  context "when adding a new record and then updating with a new set of data" do
    before do
      gateway.add_assessment(assessment_id:, document: assessment_data)
      gateway.add_assessment(assessment_id:, document: updated_assessment_data)
    end

    it "updates the record so the stored data is the updated version" do
      expect(tenure).to eq "3"
    end
  end

  context "when adding a record and then setting an individual attribute on the record" do
    context "with a simple attribute value" do
      before do
        gateway.add_assessment(assessment_id:, document: assessment_data)
        gateway.set_top_level_attribute(assessment_id:, top_level_attribute: "tenure", new_value: "5")
      end

      it "updates the record so the stored data is the updated version" do
        expect(tenure).to eq "5"
      end
    end

    context "with a datetime attribute value" do
      before do
        gateway.add_assessment(assessment_id:, document: assessment_data)
        gateway.set_top_level_attribute(assessment_id:, top_level_attribute: "tenure", new_value: "2021-11-26T14:13:11.000Z")
      end

      it "updates the record so the stored data is the updated version" do
        expect(tenure).to eq "2021-11-26T14:13:11.000Z"
      end
    end
  end

  context "when adding a record and then deleting a top-level attribute" do
    before do
      gateway.add_assessment(assessment_id:, document: assessment_data)
      gateway.delete_top_level_attribute(assessment_id:, top_level_attribute: "language_code")
    end

    it "deletes the value for the top-level attribute" do
      expect(document.key?("language_code")).to be false
    end
  end

  context "when adding a record and then deleting it" do
    before do
      gateway.add_assessment(assessment_id:, document: assessment_data)
      gateway.delete_assessment(assessment_id:)
    end

    it "deletes the whole assessment" do
      response = ActiveRecord::Base.connection.exec_query("SELECT * FROM assessment_documents WHERE assessment_id='#{assessment_id}'")
      expect(response.count).to eq 0
    end
  end

  context "when fetching the json for assessments" do
    before do
      # Assessment out of date range
      gateway.add_assessment(assessment_id:, document: assessment_data)
      Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.create(country_id: 1, assessment_id:)
      # Assessment within date
      assessment_id2 = "8570-6826-6530-4969-0203"
      assessment_data["rrn"] = assessment_id2
      gateway.add_assessment(assessment_id: assessment_id2, document: assessment_data)
      Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.create(country_id: 1, assessment_id: assessment_id2)
      Gateway::DocumentsGateway::AssessmentDocument.find_by(assessment_id: "8570-6826-6530-4969-0203").update(warehouse_created_at: Time.new(2020, 0o6, 0o1))
      # Assessment in date range that isn't in England or Wales
      assessment_id3 = "8570-6826-6530-4969-0204"
      assessment_data["rrn"] = assessment_id3
      gateway.add_assessment(assessment_id: assessment_id3, document: assessment_data)
      Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.create(country_id: 4, assessment_id: assessment_id3)
      Gateway::DocumentsGateway::AssessmentDocument.find_by(assessment_id: assessment_id3).update(warehouse_created_at: Time.new(2020, 0o6, 0o1))
    end

    it "fetches documents from England and Wales within the start and end date" do
      result = gateway.fetch_assessments(date_from: "2020-05-01", date_to: "2020-07-01")
      expect(result.count).to eq 1
      expect(result.first[:assessment_id]).to eq "8570-6826-6530-4969-0203"
    end
  end

  context "when fetching a single json document" do
    before do
      gateway.add_assessment(assessment_id:, document: assessment_data)
    end

    it "fetches the json document" do
      assessment_id = "8570-6826-6530-4969-0202"
      doc = gateway.fetch_redacted(assessment_id:)
      expect(JSON.parse(doc[:document])).to be_a Hash
      expect(doc[:assessment_id]).to eq assessment_id
    end
  end
end
