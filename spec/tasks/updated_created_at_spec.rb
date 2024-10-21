require_relative "../shared_context/shared_lodgement"

describe "rake to call the update created at values" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:push_missing_epc_to_queue") }

    include_context "when lodging XML"

    let(:data) { "1234-5678-1234-2278-1234,0000-0000-0000-0000-0000" }
    let(:redis) { MockRedis.new }
    let(:gateway) { instance_double Gateway::QueuesGateway }

    before do
      type_of_assessment = "SAP"
      schema_type = "SAP-Schema-19.0.0"
      allow($stdout).to receive(:puts)
      allow(gateway).to receive(:push_to_queue)
      allow(Container).to receive(:queues_gateway).and_return gateway
      add_assessment(assessment_id: "1234-5678-1234-2278-1234", schema_type:, type_of_assessment:)
      add_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment:)
      add_assessment(assessment_id: "0000-0000-0000-0000-0009", schema_type:, type_of_assessment:)
      update_sql = <<~SQL
        UPDATE  assessment_documents ad
         SET  document=jsonb_set(document, '{created_at}', 'null')
        WHERE assessment_id IN ('1234-5678-1234-2278-1234', '0000-0000-0000-0000-0000')
      SQL
      ActiveRecord::Base.connection.exec_query(update_sql, "SQL")
    end

    it "calls the use case to perform the refresh" do
      expect { task.invoke }.not_to raise_error
    end

    it "passes the array of assessment_ids the gateway where created_at is NULL" do
      task.invoke
      expect(gateway).to have_received(:push_to_queue).with(:assessments, data.split(","), jump_queue: true).exactly(1).times
    end
  end
end
