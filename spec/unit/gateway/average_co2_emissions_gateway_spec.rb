require_relative "../../shared_context/shared_lodgement"

describe Gateway::AverageCo2EmissionsGateway do
  subject(:gateway) { described_class.new }
  include_context "when lodging XML"

  before(:all) do
    type_of_assessment = "SAP"
    schema_type = "SAP-Schema-19.0.0"
    add_countries
    add_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment:, different_fields: {
      "co2_emissions_current_per_floor_area": 5,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment:, different_fields: {
      "co2_emissions_current_per_floor_area": 10,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment:, different_fields: {
      "co2_emissions_current_per_floor_area": 15,
    })
    Gateway::AssessmentsCountryIdGateway.new.insert(assessment_id: "0000-0000-0000-0000-0002", country_id: 2)
    add_assessment(assessment_id: "0000-0000-0000-0000-0003", schema_type:, type_of_assessment:, different_fields: {
      "co2_emissions_current_per_floor_area": 20,
      "registration_date": "2022-04-01"
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0004", schema_type:, type_of_assessment:, different_fields: {
      "co2_emissions_current_per_floor_area": 10,
      "registration_date": "2022-04-01"
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0005", schema_type:, type_of_assessment:, different_fields: {
      "co2_emissions_current_per_floor_area": 10,
      "postcode": "BT1 1AA",
      "registration_date": "2022-03-01"
    })
  end

  describe "#fetch" do
    context "when the materialised view has been populated" do
      before do
        ActiveRecord::Base.connection.exec_query("REFRESH MATERIALIZED VIEW mvw_avg_co2_emissions", "SQL")
      end

      let(:expected_values) do
        [
          {"avg_co2_emission"=>10.0, "country"=>"Northern Ireland", "year_month"=>"2022-03"},
          {"avg_co2_emission"=>15.0, "country"=>"England", "year_month"=>"2022-04"},
          {"avg_co2_emission"=>10.0, "country"=>"England", "year_month"=>"2022-05"}
        ]
      end

      it "returns the expected data" do
        expect(gateway.fetch.length).to eq 3
        expect(gateway.fetch.sort_by { |i | i["year_month"] }[0] ).to eq expected_values[0]
        expect(gateway.fetch.sort_by { |i | i["year_month"] }[1] ).to eq expected_values[1]
        expect(gateway.fetch.sort_by { |i | i["year_month"] }[2] ).to eq expected_values[2]
      end
    end
  end
end