require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_import_enums"

describe "mvw_commercial_rr_search" do

  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  context "when querying the mvw" do

    before do
      import_postcode_directory_name
      import_postcode_directory_data
      type_of_assessment = "CEPC"
      assessment_address_id = "UPRN-000000001245"
      schema_type = "CEPC-8.0.0"
      type = "cepc+rr"
      add_countries
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0000", assessment_address_id:, type:, schema_type:, type_of_assessment:, add_to_assessment_search: true, different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "registration_date": "2024-12-06"
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", assessment_address_id:, type:, schema_type:, type_of_assessment:, add_to_assessment_search: true, different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "registration_date": "2024-12-06"
      })
      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_commercial_rr_search")
    end

    let(:result) do
      ActiveRecord::Base.connection.exec_query("SELECT * FROM mvw_commercial_rr_search").map { |row| row }
    end

    it "returns data" do
      pp "assessment attribute values:"
      pp ActiveRecord::Base.connection.exec_query("SELECT * FROM assessment_attribute_values aav
         JOIN assessment_attributes aa ON aav.attribute_id = aa.attribute_id
         WHERE attribute_name LIKE '%payback%'").map { |row| row["assessment_id"] }
      pp "assessment documents:"
      pp ActiveRecord::Base.connection.exec_query("SELECT * FROM assessment_documents").map { |row| row["assessment_id"] }
      expect(result.length).to eq 40
    end

    it "returns the expected number of CEPCs" do
      expect(result.group_by { |item| item["certificate_number"] }.count).to eq 5
    end
  end
end
