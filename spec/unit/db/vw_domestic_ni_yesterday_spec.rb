require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_recommendations"

describe "Domestic NI Report Yesterday" do
  let(:date_start) { "2021-12-01" }
  let(:date_end) { "2023-12-09" }
  let(:search_arguments) do
    { date_start:, date_end: }
  end

  include_context "when fetching recommendations report"
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    add_countries

    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "RdSAP-Schema-NI-20.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "BT1 1AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0007", schema_type: "RdSAP-Schema-NI-20.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "BT1 1AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0008", schema_type: "RdSAP-Schema-NI-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "BT1 1AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0009", schema_type: "RdSAP-Schema-NI-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "BT1 1AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0010", schema_type: "RdSAP-Schema-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "SW10 0AA", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0011", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "CF10 1AA", "country_id": 2
    })
  end

  context "when calling vw_domestic_ni_yesterday" do
    let(:mvw_columns) { get_columns_from_view("mvw_domestic_ni_search") }
    let(:vw_columns) { get_columns_from_view("vw_domestic_ni_yesterday") }

    let(:vw_yesterday) { ActiveRecord::Base.connection.exec_query("SELECT * FROM vw_domestic_ni_yesterday", "SQL").map { |result| result } }

    let(:yesterday) { Time.now - 1.day }
    let(:ni_assessment_id) { "0000-0000-0000-0000-0006" }
    let(:england_assessment_id) { "0000-0000-0000-0000-0010" }
    let(:wales_assessment_id) { "0000-0000-0000-0000-0011" }

    before do
      ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{yesterday}' WHERE assessment_id = '#{england_assessment_id}'", "SQL")
      ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{yesterday}' WHERE assessment_id = '#{wales_assessment_id}'", "SQL")
      ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{yesterday}' WHERE assessment_id = '#{ni_assessment_id}'", "SQL")
    end

    it "returns the same columns as the mvw_domestic_ni_search" do
      expect(vw_columns).to eq mvw_columns
    end

    it "returns only the NI data from yesterday" do
      expect(vw_yesterday.length).to eq 1
      expect(vw_yesterday[0]["certificate_number"]).to eq(ni_assessment_id)
    end

    it "does not include the rows for England or Wales assessments" do
      expect(vw_yesterday.map { |i| i["certificate_number"] }).not_to include(england_assessment_id)
      expect(vw_yesterday.map { |i| i["certificate_number"] }).not_to include(wales_assessment_id)
    end

    it "does not include England or Wales rows even if they have an address_id_updated audit log from yesterday" do
      Gateway::AuditLogsGateway.new.insert_log(assessment_id: england_assessment_id, event_type: "address_id_updated", timestamp: yesterday)
      Gateway::AuditLogsGateway.new.insert_log(assessment_id: wales_assessment_id, event_type: "address_id_updated", timestamp: yesterday)
      expect(vw_yesterday.map { |i| i["certificate_number"] }).not_to include(england_assessment_id)
      expect(vw_yesterday.map { |i| i["certificate_number"] }).not_to include(wales_assessment_id)
    end

    it "does include NI rows if they have an address_id_updated audit log from yesterday" do
      Gateway::AuditLogsGateway.new.insert_log(assessment_id: "0000-0000-0000-0000-0009", event_type: "address_id_updated", timestamp: yesterday)
      expect(vw_yesterday.map { |i| i["certificate_number"] }).to include("0000-0000-0000-0000-0009")
    end
  end
end
