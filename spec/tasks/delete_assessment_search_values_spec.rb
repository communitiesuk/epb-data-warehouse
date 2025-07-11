require_relative "../shared_context/shared_lodgement"

describe "Adding or updating hashed assessment id node rake" do
  include_context "when lodging XML"

  context "when calling the rake task" do
    subject(:task) { get_task("one_off:delete_assessment_search_values") }

    let(:document) do
      parse_assessment(assessment_id: "9999-0000-0000-0000-9996", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", assessment_address_id: "RRN-0000-0000-0000-0000-0000", different_fields: { "postcode" => "SW10 0AA" })
    end
    let(:results) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_search",
      )
    end

    let(:ids) do
      %w[0000-0000-0000-0000-0000 0000-0000-0000-0000-0001 0000-0000-0000-0000-0002 0000-0000-0000-0000-0003 0000-0000-0000-0000-0004]
    end

    before do
      ids.each do |assessment_id|
        Gateway::AssessmentSearchGateway.new.insert_assessment(assessment_id:, document:, country_id: 1)
      end
    end

    context "when one EPC has row in audit_logs for cancelled" do
      before do
        Gateway::AuditLogsGateway.new.insert_log(assessment_id: "0000-0000-0000-0000-0000", event_type: "cancelled", timestamp: Time.now.utc)
        Gateway::AuditLogsGateway.new.insert_log(assessment_id: "0000-0000-0000-0000-0001", event_type: "opt_out", timestamp: Time.now.utc)
        task.invoke
      end

      it "assessment search has 2 rows removed from 5 added" do
        expect(results.length).to eq(3)
      end

      it "deletes the cancelled row" do
        expect(results.find { |i| i["assessment_id"] == "0000-0000-0000-0000-0000" }).to be_nil
      end

      it "deletes the opt row" do
        expect(results.find { |i| i["assessment_id"] == "0000-0000-0000-0000-0001" }).to be_nil
      end
    end
  end
end
