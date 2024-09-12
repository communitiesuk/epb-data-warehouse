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
      "registration_date": "2022-04-01",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0004", schema_type:, type_of_assessment:, different_fields: {
      "co2_emissions_current_per_floor_area": 10,
      "registration_date": "2022-04-01",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0005", schema_type:, type_of_assessment:, different_fields: {
      "co2_emissions_current_per_floor_area": 10,
      "postcode": "BT1 1AA",
      "registration_date": "2022-03-01",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0007", schema_type: "SAP-Schema-19.0.0", type_of_assessment: "SAP", different_fields: {
      "co2_emissions_current_per_floor_area": 8,
      "registration_date": "2022-12-01",
    })
  end

  before do
    Timecop.freeze(2022, 12, 2, 0, 0)
  end

  after do
    Timecop.return
  end

  describe "#fetch" do
    context "when populating the materialized view" do
      before do
        ActiveRecord::Base.connection.exec_query("REFRESH MATERIALIZED VIEW mvw_avg_co2_emissions", "SQL")
      end

      let(:expected_values) do
        [
          { "avg_co2_emission" => 10.0, "country" => "Northern Ireland", "year_month" => "2022-03", "assessment_type" => "SAP" },
          { "avg_co2_emission" => 15.0, "country" => "England", "year_month" => "2022-04", "assessment_type" => "SAP" },
          { "avg_co2_emission" => 10.0, "country" => "England", "year_month" => "2022-05", "assessment_type" => "SAP" },
        ]
      end

      it "returns the expected data excluding data for 2022-12" do
        expect(gateway.fetch.length).to eq 3
        expect(gateway.fetch.min_by { |i| i["year_month"] }).to eq expected_values[0]
        expect(gateway.fetch.sort_by { |i| i["year_month"] }[1]).to eq expected_values[1]
        expect(gateway.fetch.sort_by { |i| i["year_month"] }[2]).to eq expected_values[2]
      end

      context "when there is a row for Rdsap" do
        before do
          add_assessment(assessment_id: "0000-0000-0000-0000-1006", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", different_fields: {
            "co2_emissions_current_per_floor_area": 10,
            "registration_date": "2022-04-01",
          })
          gateway.refresh
        end

        it "returns the expected data" do
          expect(gateway.fetch.length).to eq 4
          rdsap = gateway.fetch.find { |i| i["assessment_type"] == "RdSAP" }
          expect(rdsap).to eq({ "avg_co2_emission" => 10.0, "country" => "England", "year_month" => "2022-04", "assessment_type" => "RdSAP" })
        end
      end
    end
  end

  describe "#fetch_all" do
    before do
      add_assessment(assessment_id: "0000-0000-0000-0000-0018", schema_type: "SAP-Schema-19.0.0", type_of_assessment: "SAP", different_fields: {
        "co2_emissions_current_per_floor_area": 20,
        "registration_date": "2022-05-01",
        "postcode": "BT1 1AA",
      })
    end

    let(:expected_values) do
      { "avg_co2_emission" => 12.5, "year_month" => "2022-05", "assessment_type" => "SAP" }
    end

    it "returns the averages for all countries" do
      gateway.refresh
      result = gateway.fetch_all
      row = result.find { |i| i["assessment_type"] == "SAP" && i["year_month"] = "2022-05" }
      expect(row).to eq expected_values
    end
  end

  describe "#refresh" do
    context "when the materialized view is already populated" do
      before do
        type_of_assessment = "SAP"
        schema_type = "SAP-Schema-19.0.0"
        add_assessment(assessment_id: "0000-0000-0000-0000-0006", schema_type:, type_of_assessment:, different_fields: {
          "co2_emissions_current_per_floor_area": 10,
          "postcode": "BT1 1AA",
          "registration_date": "2022-10-01",
        })
      end

      it "refreshes concurrently and returns one more row" do
        value_before = gateway.fetch.length
        expect { gateway.refresh(concurrently: true) }.not_to raise_error
        expect(gateway.fetch.length).to eq value_before + 1
      end
    end
  end
end
