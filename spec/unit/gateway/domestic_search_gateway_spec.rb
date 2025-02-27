require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"

describe Gateway::DomesticSearchGateway do
  let(:gateway) { described_class.new }
  let(:date_start) { "2021-12-01" }
  let(:date_end) { "2023-12-09" }
  let(:search_arguments) do
    { date_start:, date_end: }
  end

  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    config_path = "spec/config/attribute_enum_search_map.json"
    config_gateway = Gateway::XsdConfigGateway.new(config_path)
    import_use_case = UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: XmlPresenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway)
    import_use_case.execute
    type_of_assessment = "SAP"
    schema_type = "SAP-Schema-19.0.0"
    add_countries
    add_assessment(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment:, different_fields: {
      "postcode": "SW10 0AA",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment:, different_fields: {
      "postcode": "W6 9ZD",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0003", schema_type:, type_of_assessment:, different_fields: {
      "postcode": "BT1 1AA",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0004", schema_type:, type_of_assessment:, different_fields: {
      "registration_date": "2024-12-06", "postcode": "SW10 0AA"
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0005", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", type: "cepc", different_fields: {
      "postcode": "W6 9ZD",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0006", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "SW10 0AA",
    })
    Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_search")
  end

  describe "#initialize" do
    let(:csv_fixture) { read_csv_fixture("domestic") }

    it "returns the correct columns" do
      expect(csv_fixture.headers.sort.map(&:downcase) - gateway.columns).to eq []
    end
  end

  describe "#fetch" do
    let(:expected_data) do
      { "rrn" => "0000-0000-0000-0000-0000", "address1" => "1 Some Street", "address2" => "Some Area", "address3" => "Some County", "postcode" => "W6 9ZD", "total_floor_area" => "165", "current_energy_rating" => "72", "lodgement_date" => "2022-05-09" }
    end

    it "returns a rows for each assessment in England & Wales in ordered by rrn" do
      data = gateway.fetch(**search_arguments).sort_by { |i| i["rrn"] }
      expect(data.length).to eq 2
      expect(data[0]["rrn"]).to eq "0000-0000-0000-0000-0000"
      expect(data[1]["rrn"]).to eq "0000-0000-0000-0000-0001"
    end

    it "does not return rows with council id" do
      expect(gateway.fetch(**search_arguments)[0]["council_id"]).to be_nil
    end

    it "translates enum values into strings using the user defined function" do
      expect(gateway.fetch(**search_arguments)[0]["transaction_type"]).to eq "New dwelling"
      expect(gateway.fetch(**search_arguments)[0]["property_type"]).to eq "House"
    end

    context "when filtering by council and row limit" do
      before do
        search_arguments[:row_limit] = 2
        search_arguments[:council_id] = 1
      end

      it "returns data with a corresponding council" do
        result = gateway.fetch(**search_arguments)
        expect(result.length).to eq(2)
        expect(result[0]["rrn"]).to eq("0000-0000-0000-0000-0000")
        expect(result[1]["rrn"]).to eq("0000-0000-0000-0000-0001")
      end
    end

    context "when filtering by a date range" do
      let(:search_arguments) { { date_start: "2024-12-01", date_end: "2024-12-09" } }

      it "returns the row with a relevant data" do
        expect(gateway.fetch(**search_arguments).length).to eq(1)
        expect(gateway.fetch(**search_arguments)[0]["rrn"]).to eq("0000-0000-0000-0000-0004")
      end
    end

    context "when limiting by only by number of rows" do
      before do
        search_arguments[:row_limit] = 1
      end

      it "returns 1" do
        expect(gateway.fetch(**search_arguments).length).to eq(1)
      end
    end

    context "when checking the columns of the materialized view" do
      let(:csv_fixture) { read_csv_fixture("domestic") }

      let(:expected_sap_data) do
        { "rrn" => "0000-0000-0000-0000-0001",
          "address1" => "1 Some Street",
          "address2" => "Some Area",
          "address3" => "Some County",
          "postcode" => "SW10 0AA",
          "country" => "England",
          "region" => "E12000007",
          "report_type" => "3",
          "total_floor_area" => "165",
          "built_form" => "4",
          "inspection_date" => "2022-05-09",
          "environment_impact_current" => "94",
          "energy_consumption_current" => "59",
          "energy_consumption_potential" => "53",
          "environment_impact_potential" => "96",
          "co2_emiss_curr_per_floor_area" => "5.6",
          "co2_emissions_current" => "2.4",
          "co2_emissions_potential" => "1.4",
          "lighting_cost_current" => "123.45",
          "lighting_cost_potential" => "84.23",
          "heating_cost_current" => "365.98",
          "heating_cost_potential" => "250.34",
          "hot_water_cost_current" => "200.4",
          "hot_water_cost_potential" => "180.43",
          "main_heating_controls" => "Programmer, room thermostat and TRVs",
          "multi_glaze_proportion" => "100",
          "hotwater_description" => "From main system, waste water heat recovery",
          "hot_water_energy_eff" => "4",
          "hot_water_env_eff" => "3",
          "floor_description" => "Average thermal transmittance 0.12 W/m²K",
          "floor_energy_eff" => "5",
          "floor_env_eff" => "5",
          "windows_description" => "High performance glazing",
          "windows_energy_eff" => "0",
          "windows_env_eff" => "5",
          "walls_description" => "Average thermal transmittance 0.18 W/m²K",
          "walls_energy_eff" => "5",
          "walls_env_eff" => "5",
          "secondheat_description" => "Electric heater",
          "sheating_energy_eff" => "0",
          "sheating_env_eff" => "0",
          "roof_description" => "Average thermal transmittance 0.13 W/m²K",
          "roof_energy_eff" => "5",
          "roof_env_eff" => "5",
          "mainheat_description" => "Ground source heat pump, underfloor, electric",
          "mainheat_energy_eff" => "5",
          "mainheat_env_eff" => "5",
          "mainheatc_energy_eff" => "4",
          "mainheatc_env_eff" => "4",
          "mainheatcont_description" => "Programmer, room thermostat and TRVs",
          "lighting_description" => "Low energy lighting in 91% of fixed outlets",
          "lighting_energy_eff" => "5",
          "lighting_env_eff" => "5",
          "main_fuel" => "39",
          "wind_turbine_count" => 1,
          "mechanical_ventilation" => "1",
          "lodgement_date" => "2022-05-09",
          "posttown" => "Whitbury",
          "construction_age_band" => "England and Wales: before 1900",
          "tenure" => "1",
          "lodgement_datetime" => "2021-07-21T11:26:28.045Z",
          "fixed_lighting_outlets_count" => 11,
          "low_energy_fixed_lighting_outlets_count" => nil,
          "current_energy_efficiency" => "72",
          "current_energy_rating" => "C",
          "potential_energy_efficiency" => "72",
          "potential_energy_rating" => "C",
          "extension_count" => nil,
          "flat_storey_count" => 3,
          "flat_top_storey" => nil,
          "floor_level" => nil,
          "glazed_area" => nil,
          "heat_loss_corridor" => nil,
          "low_energy_lighting" => nil,
          "mains_gas_flag" => nil,
          "number_habitable_rooms" => nil,
          "number_heated_rooms" => nil,
          "number_open_fireplaces" => nil,
          "unheated_corridor_length" => nil,
          "building_reference_number" => "UPRN-0000000001",
          "uprn_source" => "",
          "energy_tariff" => "5",
          "floor_height" => "2.83",
          "glazed_type" => nil,
          "photo_supply" => nil,
          "solar_water_heating_flag" => nil,
          "local_authority_label" => "Hammersmith and Fulham",
          "constituency_label" => "Chelsea and Fulham",
          "constituency" => "E14000629",
          "transaction_type" => "New dwelling",
          "property_type" => "House" }
      end

      let(:expected_rdsap_data) do
        expected_sap_data.merge(
          "address2" => nil,
          "address3" => nil,
          "report_type" => "2",
          "built_form" => "2",
          "co2_emiss_curr_per_floor_area" => "20",
          "environment_impact_current" => "52",
          "environment_impact_potential" => "74",
          "extension_count" => "0",
          "construction_age_band" => "England and Wales: 2007-2011",
          "current_energy_efficiency" => "50",
          "current_energy_rating" => "E",
          "energy_consumption_current" => "230",
          "energy_consumption_potential" => "88",
          "energy_tariff" => nil,
          "fixed_lighting_outlets_count" => 16,
          "flat_storey_count" => 3,
          "flat_top_storey" => "N",
          "floor_description" => "Suspended, no insulation (assumed)",
          "floor_energy_eff" => "0",
          "floor_env_eff" => "0",
          "floor_level" => "1",
          "floor_height" => "2.52",
          "glazed_area" => "1",
          "glazed_type" => "2",
          "photo_supply" => "0",
          "solar_water_heating_flag" => "N",
          "heating_cost_current" => "365.98",
          "heating_cost_potential" => "250.34",
          "heat_loss_corridor" => "2",
          "hot_water_cost_current" => "200.4",
          "hot_water_cost_potential" => "180.43",
          "hotwater_description" => "From main system",
          "hot_water_env_eff" => "4",
          "inspection_date" => "2020-05-04",
          "lighting_cost_current" => "123.45",
          "lighting_cost_potential" => "84.23",
          "lighting_description" => "Low energy lighting in 50% of fixed outlets",
          "lighting_energy_eff" => "4",
          "lighting_env_eff" => "4",
          "lodgement_date" => "2020-05-04",
          "low_energy_lighting" => "100",
          "low_energy_fixed_lighting_outlets_count" => "16",
          "main_fuel" => "26",
          "mains_gas_flag" => "Y",
          "mechanical_ventilation" => "0",
          "multi_glaze_proportion" => "100",
          "number_habitable_rooms" => "5",
          "number_heated_rooms" => "5",
          "number_open_fireplaces" => "0",
          "roof_description" => "Pitched, 25 mm loft insulation",
          "roof_energy_eff" => "2",
          "roof_env_eff" => "2",
          "rrn" => "0000-0000-0000-0000-0006",
          "secondheat_description" => "Room heaters, electric",
          "total_floor_area" => "55",
          "main_heating_controls" => "Programmer, room thermostat and TRVs. Time and temperature zone control",
          "building_reference_number" => "UPRN-000000000000",
          "unheated_corridor_length" => "10",
          "walls_description" => "Solid brick, as built, no insulation (assumed)",
          "walls_energy_eff" => "1",
          "walls_env_eff" => "1",
          "wind_turbine_count" => 0,
          "windows_description" => "Fully double glazed",
          "windows_energy_eff" => "3",
          "windows_env_eff" => "3",
        )
      end

      let(:query_result) do
        search_arguments[:date_start] = "2020-04-04"
        gateway.fetch(**search_arguments)
      end

      it "returns the correct columns" do
        expect(csv_fixture.headers.sort.map(&:downcase) - expected_sap_data.keys).to eq []
      end

      it "returns a row with the required data for SAP" do
        result = query_result.find { |i| i["rrn"] == "0000-0000-0000-0000-0001" }
        expect(result).to eq expected_sap_data
      end

      it "returns a row with the required data for RdSAP" do
        result = query_result.find { |i| i["rrn"] == "0000-0000-0000-0000-0006" }

        expect(result).to eq expected_rdsap_data
      end
    end
  end
end
