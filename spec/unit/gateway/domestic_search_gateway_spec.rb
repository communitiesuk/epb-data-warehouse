require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"

describe Gateway::DomesticSearchGateway do
  let(:gateway) { described_class.new }

  include_context "when lodging XML"
  include_context "when saving ons data"

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    config_path = "spec/config/attribute_enum_search_map.json"
    config_gateway = Gateway::XsdConfigGateway.new(config_path)
    import_use_case = UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: XmlPresenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway)
    import_use_case.execute
  end

  describe "#fetch" do
    before do
      type_of_assessment = "SAP"
      schema_type = "SAP-Schema-19.0.0"
      add_countries
      add_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment:)
      add_assessment(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment:)
      add_assessment(assessment_id: "0000-0000-0000-0000-0003", schema_type:, type_of_assessment:, different_fields: {
        "postcode": "BT1 1AA",
      })
      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_search")
    end

    let(:expected_data) do
      { "rrn" => "0000-0000-0000-0000-0000", "address1" => "1 Some Street", "address2" => "Some Area", "address3" => "Some County", "postcode" => "A0 0AA", "total_floor_area" => "165", "current_energy_rating" => "72", "lodgement_date" => "2022-05-09" }
    end

    it "returns a rows for each assessment in England & Wales" do
      expect(gateway.fetch.length).to eq 2
      expect(gateway.fetch[0]["rrn"]).to eq "0000-0000-0000-0000-0000"
      expect(gateway.fetch[1]["rrn"]).to eq "0000-0000-0000-0000-0001"
    end

    it "returns expected values for the first row" do
      expect(gateway.fetch[0]).to match a_hash_including expected_data
    end

    it "translates enum values into strings using the user defined function" do
      expect(gateway.fetch[0]["transaction_type"]).to eq "New dwelling"
      expect(gateway.fetch[0]["property_type"]).to eq "House"
    end

    context "when filtering by council" do
    end

    context "when filtering by a date range" do
    end

    context "when limiting by number of row" do
    end
  end
end
