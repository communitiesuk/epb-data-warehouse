require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_recommendations"

describe "Domestic NI Recommendations Report Yesterday" do
  include_context "when fetching recommendations report"
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  let(:query_result) do
    ActiveRecord::Base.connection.exec_query("SELECT * FROM vw_domestic_ni_rr_yesterday ORDER BY certificate_number, improvement_item", "SQL").map { |result| result }
  end

  let(:mvw_columns) { get_columns_from_view("mvw_domestic_ni_rr_search") }
  let(:vw_columns) { get_columns_from_view("vw_domestic_ni_rr_yesterday") }
  let(:certificate_numbers) { query_result.map { |row| row["certificate_number"] }.uniq }
  let(:yesterday) { Date.today - 1 }
  let(:england_assessment_id) { "0000-0000-0000-0000-0010" }
  let(:wales_assessment_id) { "0000-0000-0000-0000-0011" }
  let(:ni_yesterday_assessment_id) { "0000-0000-0000-0000-0012" }
  let(:ni_not_yesterday_assessment_id) { "0000-0000-0000-0000-0006" }

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data

    config_path = "spec/config/attribute_improvements_map.json"
    config_gateway = Gateway::XsdConfigGateway.new(config_path)
    import_use_case = UseCase::ImportEnums.new(
      assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new,
      xsd_presenter: XmlPresenter::Xsd.new,
      assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new,
      xsd_config_gateway: config_gateway,
    )
    import_use_case.execute
    add_countries

    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0010", schema_type: "RdSAP-Schema-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "SW10 0AA", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0011", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "CF10 1AA", "country_id": 2
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0012", schema_type: "SAP-Schema-NI-16.1", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "RdSAP-Schema-NI-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "BT1 0AA", "country_id": 3
    })
  end

  before do
    ActiveRecord::Base.connection.exec_query("UPDATE assessment_documents SET warehouse_created_at = '#{yesterday}' WHERE assessment_id = '#{england_assessment_id}'", "SQL")
    ActiveRecord::Base.connection.exec_query("UPDATE assessment_documents SET warehouse_created_at = '#{yesterday}' WHERE assessment_id = '#{wales_assessment_id}'", "SQL")
    ActiveRecord::Base.connection.exec_query("UPDATE assessment_documents SET warehouse_created_at = '#{yesterday}' WHERE assessment_id = '#{ni_yesterday_assessment_id}'", "SQL")
  end

  it "returns the same columns as the mvw_domestic_rr_search" do
    expect(vw_columns).to eq mvw_columns
  end

  it "returns only the NI recommendations from yesterday" do
    expect(certificate_numbers).to eq [ni_yesterday_assessment_id]
  end

  it "does not include England or Wales recommendations" do
    expect(certificate_numbers).not_to include(england_assessment_id)
    expect(certificate_numbers).not_to include(wales_assessment_id)
  end

  it "does not include NI recommendations that were not created yesterday" do
    expect(certificate_numbers).not_to include(ni_not_yesterday_assessment_id)
  end
end
