shared_context "when requesting a search endpoint" do |property_type|
  include RSpecDataWarehouseApiServiceMixin

  include_context "when lodging XML"
  include_context "when saving ons data"

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    add_countries

    country_id = 1

    type_of_assessment = property_type == "domestic" ? "RdSAP" : "CEPC"
    type = property_type == "domestic" ? "epc" : "cepc"
    schema_type = property_type == "domestic" ? "RdSAP-Schema-20.0.0" : "CEPC-8.0.0"

    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment:, type:, add_to_assessment_search: true, different_fields: {
      country_id:, "postcode" => "SW10 0AA", assessment_address_id: "UPRN-100121241798"
    }.merge(property_type == "domestic" ? { "energy_rating_current" => 85 } : { "asset_rating" => 35, "related_rrn" => "0000-0000-0000-0000-1111" }))
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment:, type:, add_to_assessment_search: true, different_fields: {
      country_id:, "postcode" => "SW1A 2AA", assessment_address_id: "UPRN-100121241799"
    }.merge(property_type == "domestic" ? {} : { "related_rrn" => "0000-0000-0000-0000-2222" }))
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment:, type:, add_to_assessment_search: true, different_fields: {
      country_id:, "postcode" => "ML9 9AR"
    }.merge(property_type == "domestic" ? {} : { "related_rrn" => "0000-0000-0000-0000-3333" }))
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0003", schema_type:, type_of_assessment:, type:, add_to_assessment_search: true, different_fields: {
      country_id:, "postcode" => "SW10 0AA", "address_line_1" => "2 Banana Street"
    }.merge(property_type == "domestic" ? {} : { "related_rrn" => "0000-0000-0000-0000-4444" }))
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0004", schema_type: "SAP-Schema-19.0.0", type_of_assessment: "SAP", type: "epc", add_to_assessment_search: true, different_fields: {
      country_id:, "postcode" => "SW10 0AA", "energy_rating_current" => 72
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0005", schema_type:, type_of_assessment:, type:, add_to_assessment_search: true, different_fields: {
      country_id:, "postcode" => "SW10 0AA", "asset_rating" => 110, "created_at" => Date.today.strftime("%y-%m-%d")
    }.merge(property_type == "domestic" ? { "energy_rating_current" => 85 } : { "asset_rating" => 35, "related_rrn" => "0000-0000-0000-0000-1111" }))
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0099", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", type: "cepc", add_to_assessment_search: true, different_fields: {
      country_id:, "postcode" => "SW10 0AA"
    }.merge(property_type == "domestic" ? {} : { "asset_rating" => 110, "related_rrn" => "0000-0000-0000-0000-1111" }))
  end
end
