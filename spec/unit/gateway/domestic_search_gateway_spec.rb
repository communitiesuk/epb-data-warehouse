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
      let(:expected_data) do
        { "rrn" => "0000-0000-0000-0000-0001",
          "address1" => "1 Some Street",
          "address2" => "Some Area",
          "address3" => "Some County",
          "postcode" => "SW10 0AA",
          "total_floor_area" => "165",
          "current_energy_rating" => "72",
          "lodgement_date" => "2022-05-09",
          "local_authority_label" => "Hammersmith and Fulham",
          "constituency_label" => "Chelsea and Fulham",
          "transaction_type" => "New dwelling",
          "property_type" => "House",
          "full_address" => "1 some street some area some county whitbury" }
      end

      let(:first_query_result) do
        ActiveRecord::Base.connection.exec_query(
          "SELECT
    ad.assessment_id as RRN,
    document ->> 'address_line_1' as ADDRESS1,
    document ->> 'address_line_2' as ADDRESS2,
    document ->> 'address_line_3' as ADDRESS3,
    document ->> 'postcode' as POSTCODE,
    document ->> 'total_floor_area' as TOTAL_FLOOR_AREA,
    document->>'energy_rating_current' as CURRENT_ENERGY_RATING,
    document->>'registration_date' as LODGEMENT_DATE,
    os_la.name as LOCAL_AUTHORITY_LABEL,
    os_p.name as CONSTITUENCY_LABEL,
    get_lookup_value('transaction_type', document ->> 'transaction_type', document ->> 'assessment_type', document->> 'schema_type' ) as TRANSACTION_TYPE,
    get_lookup_value('property_type', document ->> 'property_type', document ->> 'assessment_type', document->> 'schema_type' ) as PROPERTY_TYPE,


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
  AND co.country_code IN ('EAW', 'ENG', 'WLS')",
        ).first
      end

      it "creates a table with the required data" do
        expect(first_query_result).to eq expected_data
      end
    end
  end
end
