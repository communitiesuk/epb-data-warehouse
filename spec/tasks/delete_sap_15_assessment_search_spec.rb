describe "Delete SAP 15 certificates from assessment_search rake" do
  include_context "when lodging XML"

  before do
    ActiveRecord::Base.connection.execute("TRUNCATE assessment_search")
  end

  context "when calling the rake task" do
    subject(:task) { get_task("one_off:delete_sap_15_assessment_search") }

    let(:results) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_search",
      )
    end

    before do
      assessment_address_id = "UPRN-000000001245"
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0000", assessment_address_id:, schema_type: "SAP-Schema-15.0", type_of_assessment: "SAP", type: "sap", add_to_assessment_search: true, different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", assessment_address_id:, schema_type: "SAP-Schema-15.0", type_of_assessment: "SAP", type: "rdsap", add_to_assessment_search: true, different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", assessment_address_id:, schema_type: "SAP-Schema-19.0.0", type_of_assessment: "SAP", type: "epc", add_to_assessment_search: true, different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0003", assessment_address_id:, schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", type: "epc", add_to_assessment_search: true, different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
    end

    it "deletes only SAP 15.0 certificates" do
      task.invoke
      expect(results.length).to eq(2)
      expect(results { |i| i["assessment_id"] }.map { |i| i["assessment_id"] }).to eq %w[0000-0000-0000-0000-0002 0000-0000-0000-0000-0003]
    end
  end
end
