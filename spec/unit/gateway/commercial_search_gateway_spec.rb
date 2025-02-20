require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"

describe Gateway::CommercialSearchGateway do
  subject(:gateway) { described_class.new }

  context "when creating commercial materialized view" do
    include_context "when lodging XML"
    include_context "when saving ons data"
    include_context "when exporting data"
    before do
      attributes_gateway = Gateway::AssessmentAttributesGateway.new
      attributes_gateway.clear

      import_postcode_directory_name
      import_postcode_directory_data
      config_path = "spec/config/attribute_enum_search_map.json"
      config_gateway = Gateway::XsdConfigGateway.new(config_path)
      import_use_case = UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: XmlPresenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway)
      import_use_case.execute

      add_countries
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0005", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", type: "cepc", different_fields: {
        "postcode": "W6 9ZD", "address1": "1 Some Street", "address2": "Some Area", "address3": "Some County", "property_type": "B1 Offices and Workshop businesses", "building_emissions": "67.09"
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", type: "cepc", different_fields: {
        "postcode": "W6 9ZD",
      })
    end

    let(:expected_data) do
      { "assessment_id" => "0000-0000-0000-0000-0005",
        "address1" => "1 Some Street",
        "address2" => "Some Area",
        "address3" => "Some County",
        "postcode" => "W6 9ZD",
        "property_type" => "B1 Offices and Workshop businesses" }
    end
    let(:first_query_result) do
      ActiveRecord::Base.connection.exec_query("SELECT
      get_attribute_value('postcode', aav.assessment_id) as postcode,
      get_attribute_value('property_type', aav.assessment_id) as property_type,
      get_attribute_value('address1', aav.assessment_id) as address1,
      get_attribute_value('address2', aav.assessment_id) as address2,
      get_attribute_value('address3', aav.assessment_id) as address3,
      aav.assessment_id as assessment_id
FROM assessment_attribute_values aav
JOIN (SELECT aav2.assessment_id, aav2.attribute_value as assessment_type
                       FROM assessment_attribute_values aav2
                       JOIN public.assessment_attributes a2 on aav2.attribute_id = a2.attribute_id
                       WHERE a2.attribute_name = 'assessment_type')  as t
                      ON t.assessment_id = aav.assessment_id
join assessments_country_ids aci on aav.assessment_id = aci.assessment_id
join countries co on aci.country_id = co.country_id
AND t.assessment_type = 'CEPC'
  AND co.country_code IN ('EAW', 'ENG', 'WLS');").first
    end

    it "creates a table with the required data" do
      expect(first_query_result).to eq expected_data
    end
  end
end
