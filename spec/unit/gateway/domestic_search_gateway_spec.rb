require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"

describe Gateway::DomesticSearchGateway do
  let(:gateway) { described_class.new }
  let(:date_start) { "2021-12-01" }
  let(:date_end) { "2023-12-09" }

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

    let(:expected_data) do
      { "rrn" => "0000-0000-0000-0000-0000", "address1" => "1 Some Street", "address2" => "Some Area", "address3" => "Some County", "postcode" => "W6 9ZD", "total_floor_area" => "165", "current_energy_rating" => "72", "lodgement_date" => "2022-05-09" }
    end

    it "returns a rows for each assessment in England & Wales in ordered by rrn" do
      expect(gateway.fetch(date_start:, date_end:).length).to eq 2
      expect(gateway.fetch(date_start:, date_end:)[0]["rrn"]).to eq "0000-0000-0000-0000-0000"
      expect(gateway.fetch(date_start:, date_end:)[1]["rrn"]).to eq "0000-0000-0000-0000-0001"
    end

    it "returns expected values for the first row" do
      expect(gateway.fetch(date_start:, date_end:)[0]).to match a_hash_including expected_data
    end

    it "translates enum values into strings using the user defined function" do
      expect(gateway.fetch(date_start:, date_end:)[0]["transaction_type"]).to eq "New dwelling"
      expect(gateway.fetch(date_start:, date_end:)[0]["property_type"]).to eq "House"
    end

    context "when filtering by council and row limit" do
      let(:council) { "Hammersmith and Fulham" }
      let(:row_limit) { 2 }

      it "returns data with a corresponding council" do
        result = gateway.fetch(date_start:, date_end:, council:, row_limit:)
        expect(result.length).to eq(2)
        expect(result[0]["rrn"]).to eq("0000-0000-0000-0000-0000")
        expect(result[1]["rrn"]).to eq("0000-0000-0000-0000-0001")
      end
    end

    context "when filtering by a date range" do
      let(:date_start) { "2024-12-01" }
      let(:date_end) { "2024-12-09" }

      it "returns the row with a relevant data" do
        expect(gateway.fetch(date_start:, date_end:).length).to eq(1)
        expect(gateway.fetch(date_start:, date_end:)[0]["rrn"]).to eq("0000-0000-0000-0000-0004")
      end
    end

    context "when limiting by only by number of rows" do
      let(:row_limit) { 1 }

      it "returns 1" do
        expect(gateway.fetch(date_start:, date_end:, row_limit:).length).to eq(1)
      end
    end

    context "when creating the materialized view" do
      let(:expected_base_data) do
        { "rrn" => "0000-0000-0000-0000-0001",
          "address1" => "1 Some Street",
          "address2" => "Some Area",
          "address3" => "Some County",
          "postcode" => "SW10 0AA",
          "total_floor_area" => "165",
          "built_form" => "4",
          "inspection_date" => "2022-05-09",
          "environmental_impact_current" => "94",
          "energy_consumption_current" => "59",
          "energy_consumption_potential" => "53",
          "environmental_impact_potential" => "96",
          "co2_emissions_curr_per_floor_area" => "5.6",
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
          "hotwater_efficiency_rating" => "4",
          "hotwater_environmental_rating" => "3",
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
          "construction_age_band" => "A",
          "tenure" => "1",
          "lodgement_datetime" => "2021-07-21T11:26:28.045Z",
          "fixed_lighting_outlets_count" => 11,
          "low_energy_fixed_light_count" => nil,
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
          "uprn" => "UPRN-0000000001",
          "uprn_source" => "",
          "energy_tariff" => "5",
          "floor_height" => 2.83,
          "glazed_type" => nil,
          "photo_supply" => nil,
          "solar_water_heating_flag" => nil,
          "local_authority_label" => "Hammersmith and Fulham",
          "constituency_label" => "Chelsea and Fulham",
          "constituency" => "E14000629",
          "transaction_type" => "New dwelling",
          "property_type" => "House",
          "full_address" => "1 some street some area some county whitbury" }
      end

      let(:expected_rdsap_data) do
        expected_base_data.merge(
          "address2" => nil,
          "address3" => nil,
          "built_form" => "2",
          "co2_emissions_curr_per_floor_area" => "20",
          "environmental_impact_current" => "52",
          "environmental_impact_potential" => "74",
          "extension_count" => "0",
          "construction_age_band" => "K",
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
          "floor_height" => 2.52,
          "full_address" => "1 some street whitbury",
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
          "hotwater_environmental_rating" => "4",
          "inspection_date" => "2020-05-04",
          "lighting_cost_current" => "123.45",
          "lighting_cost_potential" => "84.23",
          "lighting_description" => "Low energy lighting in 50% of fixed outlets",
          "lighting_energy_eff" => "4",
          "lighting_env_eff" => "4",
          "lodgement_date" => "2020-05-04",
          "low_energy_lighting" => "100",
          "low_energy_fixed_light_count" => "16",
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
          "uprn" => "UPRN-000000000000",
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

      let(:sql_query) do
        "SELECT
    ad.assessment_id as RRN,
    document ->> 'address_line_1' as ADDRESS1,
    document ->> 'address_line_2' as ADDRESS2,
    document ->> 'address_line_3' as ADDRESS3,
    document ->> 'postcode' as POSTCODE,
    document ->> 'inspection_date' AS INSPECTION_DATE,
    document ->> 'environmental_impact_potential' AS ENVIRONMENTAL_IMPACT_POTENTIAL,
    document ->> 'energy_consumption_current' AS ENERGY_CONSUMPTION_CURRENT,
    document ->> 'energy_consumption_potential' AS ENERGY_CONSUMPTION_POTENTIAL,
    document ->> 'environmental_impact_current' AS ENVIRONMENTAL_IMPACT_CURRENT,
    document ->> 'co2_emissions_current' AS CO2_EMISSIONS_CURRENT,
    document ->> 'co2_emissions_current_per_floor_area' AS CO2_EMISSIONS_CURR_PER_FLOOR_AREA,
    document ->> 'co2_emissions_potential' AS CO2_EMISSIONS_POTENTIAL,
    document -> 'hot_water' ->> 'description' as HOTWATER_DESCRIPTION,
    document -> 'hot_water' ->> 'energy_efficiency_rating' as HOTWATER_EFFICIENCY_RATING,
    document -> 'hot_water' ->> 'environmental_efficiency_rating' as HOTWATER_ENVIRONMENTAL_RATING,
    document -> 'floors' -> 0 ->> 'description' as FLOOR_DESCRIPTION,
    document -> 'floors' -> 0 ->> 'energy_efficiency_rating' as FLOOR_ENERGY_EFF,
    document -> 'floors' -> 0 ->> 'environmental_efficiency_rating' as FLOOR_ENV_EFF,
    document -> 'secondary_heating' ->> 'description' as SECONDHEAT_DESCRIPTION,
    document -> 'secondary_heating' ->> 'energy_efficiency_rating' as SHEATING_ENERGY_EFF,
    document -> 'secondary_heating' ->> 'environmental_efficiency_rating' as SHEATING_ENV_EFF,
    document -> 'roofs' -> 0 ->> 'description' as ROOF_DESCRIPTION,
    document -> 'roofs' -> 0 ->> 'energy_efficiency_rating' as ROOF_ENERGY_EFF,
    document -> 'roofs' -> 0 ->> 'environmental_efficiency_rating' as ROOF_ENV_EFF,
    document -> 'main_heating' -> 0 ->> 'description' as MAINHEAT_DESCRIPTION,
    document -> 'main_heating' -> 0 ->> 'energy_efficiency_rating' as MAINHEAT_ENERGY_EFF,
    document -> 'main_heating' -> 0 ->> 'environmental_efficiency_rating' as MAINHEAT_ENV_EFF,
    document -> 'main_heating_controls' -> 0 ->> 'description' as MAINHEATCONT_DESCRIPTION,
    document -> 'main_heating_controls' -> 0 ->> 'energy_efficiency_rating' as MAINHEATC_ENERGY_EFF,
    document -> 'main_heating_controls' -> 0 ->> 'environmental_efficiency_rating' as MAINHEATC_ENV_EFF,
    document -> 'lighting' ->> 'description' as LIGHTING_DESCRIPTION,
    document -> 'lighting' ->> 'energy_efficiency_rating' as LIGHTING_ENERGY_EFF,
    document -> 'lighting' ->> 'environmental_efficiency_rating' as LIGHTING_ENV_EFF,
    document ->> 'total_floor_area' as TOTAL_FLOOR_AREA,
    document ->> 'registration_date' as LODGEMENT_DATE,
    document ->> 'post_town' as POSTTOWN,
    document ->> 'tenure' as TENURE,
    document ->> 'created_at' as LODGEMENT_DATETIME,
    document ->> 'energy_rating_current' as CURRENT_ENERGY_EFFICIENCY,
    energy_band_calculator((document ->> 'energy_rating_current')::int, document ->> 'assessment_type') as CURRENT_ENERGY_RATING,
    document ->> 'energy_rating_potential' AS POTENTIAL_ENERGY_EFFICIENCY,
    energy_band_calculator((document ->> 'energy_rating_potential')::int, document ->> 'assessment_type') as POTENTIAL_ENERGY_RATING,
    document ->> 'glazed_area' as GLAZED_AREA,
    document -> 'sap_data' ->> 'extensions_count' as EXTENSION_COUNT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'built_form' ELSE document ->> 'built_form' END AS BUILT_FORM,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_flat_details' ->> 'unheated_corridor_length' ELSE document ->> 'unheated_corridor_length' END AS UNHEATED_CORRIDOR_LENGTH,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'open_fireplaces_count' ELSE document ->> 'open_fireplaces_count' END AS NUMBER_OPEN_FIREPLACES,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'heated_room_count' ELSE document ->> 'heated_room_count' END AS NUMBER_HEATED_ROOMS,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'habitable_room_count' ELSE document ->> 'habitable_room_count' END AS NUMBER_HABITABLE_ROOMS,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_energy_source' ->> 'mains_gas' ELSE document ->> 'mains_gas' END AS MAINS_GAS_FLAG,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_energy_source' -> 'photovoltaic_supply' -> 'none_or_no_details' ->> 'percent_roof_area' ELSE document -> 'sap_energy_source' -> 'photovoltaic_supply' -> 'none_or_no_details' ->> 'percent_roof_area' END AS PHOTO_SUPPLY,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_energy_source' ->> 'electricity_tariff' ELSE document -> 'sap_energy_source' ->> 'electricity_tariff' END AS ENERGY_TARIFF,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'low_energy_lighting' ELSE document ->> 'low_energy_lighting' END AS LOW_ENERGY_LIGHTING,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'low_energy_fixed_lighting_outlets_count' ELSE document ->> 'low_energy_fixed_lighting_bulbs_count' END AS LOW_ENERGY_FIXED_LIGHT_COUNT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_flat_details' ->> 'heat_loss_corridor' ELSE document ->> 'heat_loss_corridor' END AS HEAT_LOSS_CORRIDOR,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'glazed_area' ELSE document ->> 'glazed_area' END as GLAZED_AREA,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'multiple_glazing_type' ELSE document ->> 'multiple_glazing_type' END as GLAZED_TYPE,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_flat_details' ->> 'level' ELSE document ->> 'level' END AS FLOOR_LEVEL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_flat_details' ->> 'top_storey' ELSE document ->> 'top_storey' END AS FLAT_TOP_STOREY,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN (document -> 'sap_data' -> 'sap_flat_details' ->> 'storey_count')::int ELSE COALESCE(jsonb_array_length(document -> 'sap_building_parts' -> 0 -> 'sap_floor_dimensions'), 0) END AS FLAT_STOREY_COUNT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'window' ->> 'description' ELSE document -> 'windows' ->> 'description' END AS WINDOWS_DESCRIPTION,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'window' ->> 'energy_efficiency_rating' ELSE document -> 'windows' ->> 'energy_efficiency_rating' END AS WINDOWS_ENERGY_EFF,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'window' ->> 'environmental_efficiency_rating' ELSE document -> 'windows' ->> 'environmental_efficiency_rating' END AS WINDOWS_ENV_EFF,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_heating' -> 'main_heating_details' -> 0 ->> 'main_fuel_type' ELSE document -> 'sap_heating' -> 'main_heating_details' -> 0 ->> 'main_fuel_type' END MAIN_FUEL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN (document -> 'sap_data' -> 'sap_energy_source' ->> 'wind_turbines_count')::int ELSE COALESCE(jsonb_array_length(document -> 'sap_energy_source' -> 'wind_turbines'), 0)  END AS WIND_TURBINE_COUNT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'wall' ->> 'environmental_efficiency_rating' ELSE document -> 'walls' -> 0 ->> 'environmental_efficiency_rating' END AS WALLS_ENV_EFF,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'wall' ->> 'description' ELSE document -> 'walls' -> 0 ->> 'description' END AS WALLS_DESCRIPTION,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'wall' ->> 'energy_efficiency_rating' ELSE document -> 'walls' -> 0 ->> 'energy_efficiency_rating' END AS WALLS_ENERGY_EFF,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'lighting_cost_current' ELSE document -> 'lighting_cost_current' ->> 'value' END AS LIGHTING_COST_CURRENT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'lighting_cost_potential' ELSE document -> 'lighting_cost_potential' ->> 'value' END AS LIGHTING_COST_POTENTIAL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'heating_cost_current' ELSE document -> 'heating_cost_current' ->> 'value' END AS HEATING_COST_CURRENT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'heating_cost_potential' ELSE document -> 'heating_cost_potential' ->> 'value' END AS HEATING_COST_POTENTIAL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'hot_water_cost_current' ELSE document -> 'hot_water_cost_current' ->> 'value' END AS HOT_WATER_COST_CURRENT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'hot_water_cost_potential' ELSE document -> 'hot_water_cost_potential' ->> 'value' END AS HOT_WATER_COST_POTENTIAL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'multiple_glazed_proportion' ELSE document ->> 'multiple_glazed_percentage' END AS MULTI_GLAZE_PROPORTION,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'solar_water_heating' ELSE document ->> 'solar_water_heating' END AS SOLAR_WATER_HEATING_FLAG,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_heating' -> 'main_heating_details' -> 0 ->> 'main_fuel_type' ELSE document -> 'sap_heating' -> 'main_heating_details' -> 0 ->> 'main_fuel_type' END MAIN_FUEL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_building_parts'-> 0 ->> 'construction_age_band' ELSE document -> 'sap_building_parts'-> 0 ->> 'construction_age_band' END as CONSTRUCTION_AGE_BAND,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'mechanical_ventilation' ELSE document -> 'sap_ventilation' ->> 'mechanical_ventilation_data_source' END AS MECHANICAL_VENTILATION,
    CASE WHEN document ->> 'uprn' LIKE 'UPRN-%' THEN document ->> 'uprn' ELSE '' END as UPRN,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP'
      THEN (
          SELECT ROUND(AVG((sfd -> 'room_height' ->> 'value')::numeric), 2)
          FROM jsonb_array_elements((document -> 'sap_data' -> 'sap_building_parts' -> 0 -> 'sap_floor_dimensions')) AS sfd
      )
      ELSE (
          SELECT ROUND(AVG((sfd ->> 'storey_height')::numeric), 2)
          FROM jsonb_array_elements((document -> 'sap_building_parts' -> 0 -> 'sap_floor_dimensions')) AS sfd
      )
    END AS FLOOR_HEIGHT,

    CASE WHEN document ->> 'assessment_type' = 'RdSAP'
      THEN ((document -> 'sap_data' ->> 'fixed_lighting_outlets_count')::integer)
    ELSE (
      SELECT (SUM(COALESCE((sl ->> 'lighting_outlets')::integer, 0))::integer)
      FROM jsonb_array_elements((document -> 'sap_lighting' -> 0)) AS sl
    )
    END AS FIXED_LIGHTING_OUTLETS_COUNT,

    '' as UPRN_SOURCE,
    os_la.name as LOCAL_AUTHORITY_LABEL,
    os_p.name as CONSTITUENCY_LABEL,
    os_p.area_code as CONSTITUENCY,
    get_lookup_value('transaction_type', document ->> 'transaction_type', document ->> 'assessment_type', document->> 'schema_type' ) as TRANSACTION_TYPE,
    get_lookup_value('property_type', document ->> 'property_type', document ->> 'assessment_type', document->> 'schema_type' ) as PROPERTY_TYPE,

    (
      SELECT STRING_AGG(mhc ->> 'description', '. ')
      FROM jsonb_array_elements(document -> 'main_heating_controls') AS mhc
    ) AS MAIN_HEATING_CONTROLS,

    LOWER(CONCAT_WS(' ', (document ->> 'address_line_1')::varchar,
                    (document ->> 'address_line_2')::varchar,
                    (document ->> 'address_line_3')::varchar,
                    (document ->> 'post_town')::varchar)) as full_address
FROM assessment_documents ad
join assessments_country_ids aci on ad.assessment_id = aci.assessment_id
join countries co on aci.country_id = co.country_id
left JOIN ons_postcode_directory ons on document ->> 'postcode' = ons.postcode
left join ons_postcode_directory_names os_la on ons.local_authority_code = os_la.area_code
left join ons_postcode_directory_names os_p on ons.westminster_parliamentary_constituency_code = os_p.area_code
WHERE document ->> 'assessment_type' IN ('RdSAP', 'SAP')
  AND co.country_code IN ('EAW', 'ENG', 'WLS')"
      end

      it "creates a table with the required data for SAP" do
        first_query_result = ActiveRecord::Base.connection.exec_query(sql_query).first
        expect(first_query_result).to eq expected_base_data
      end

      it "creates a table with the required data for RdSAP" do
        sql_query << " AND document ->> 'assessment_type' = 'RdSAP'"
        first_query_result = ActiveRecord::Base.connection.exec_query(sql_query).first
        expect(first_query_result).to eq expected_rdsap_data
      end
    end
  end
end
