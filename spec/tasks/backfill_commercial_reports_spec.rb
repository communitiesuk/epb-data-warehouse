shared_context "when inserting cepc documents" do
  def save_new_cepc(schema:, assessment_id:, assessment_type:, sample_type:, related_rrn:, country_id: 1, created_at: nil, postcode: nil)
    sample = Samples.xml(schema, sample_type)
    use_case = UseCase::ParseXmlCertificate.new
    parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id:)
    parsed_epc["assessment_type"] = assessment_type
    parsed_epc["schema_type"] = schema
    parsed_epc["created_at"] = created_at.to_s unless created_at.nil?
    parsed_epc["registration_date"] = created_at.to_s unless created_at.nil?
    parsed_epc["postcode"] = postcode unless postcode.nil?
    parsed_epc["assessment_address_id"] = "UPRN-1000000001245"
    parsed_epc["related_rrn"] = related_rrn
    import = Gateway::DocumentsGateway.new
    import.add_assessment(assessment_id:, document: parsed_epc)
    country_gateway = Gateway::AssessmentsCountryIdGateway.new
    country_gateway.insert(assessment_id:, country_id:) unless country_id.nil?
  end
end

require_relative "../shared_context/shared_lodgement"
describe "Backfill commercial_reports table rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:backfill_commercial_reports") }

    include_context "when inserting cepc documents"

    let(:result) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM commercial_reports",
      )
    end

    before do
      allow($stdout).to receive(:puts)
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
    end

    context "when certificates have been saved" do
      before do
        save_new_cepc(schema: "CEPC-8.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "CEPC", sample_type: "cepc", related_rrn: "0000-0000-0000-0000-1111")
        save_new_cepc(schema: "CEPC-7.1", assessment_id: "1111-1111-1111-1111-1111", assessment_type: "DEC", sample_type: "dec+rr", related_rrn: "0000-0000-0000-0000-2222")
      end

      it "CEPCs are saved into commercial_reports table" do
        task.invoke
        expect(result.length).to eq(2)
      end

      it "shows a message of the assessments count to be backfilled" do
        expect { task.invoke }.to output(/Total assessments to back fill: 2/).to_stdout
      end

      it "inserting a duplicate assessment does not raise an error" do
        task.invoke
        task.reenable
        expect { task.invoke }.not_to raise_error
        expect(result.length).to eq(2)
      end

      it "inserting a duplicate assessment does not call the commercial reports gateway" do
        task.invoke

        gateway_instance = instance_double(Gateway::CommercialReportsGateway)
        allow(gateway_instance).to receive(:insert_report)
        allow(Gateway::CommercialReportsGateway).to receive(:new).and_return(gateway_instance)

        task.reenable
        expect { task.invoke }.to output(/Total assessments to back fill: 0/).to_stdout
        expect(gateway_instance).to have_received(:insert_report).exactly(0).times
      end

      it "doesn't insert domestic assessment types" do
        save_new_cepc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-1111", assessment_type: "RdSAP", sample_type: "epc", related_rrn: "0000-0000-0000-0000-3333")
        save_new_cepc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", assessment_type: "SAP", sample_type: "epc", related_rrn: "0000-0000-0000-0000-4444")
        task.invoke
        expect(result.length).to eq(2)
      end

      it "doesn't insert assessments without related_rrn" do
        save_new_cepc(schema: "CEPC-8.0.0", assessment_id: "2222-2222-2222-2222-2222", assessment_type: "DEC", sample_type: "dec-rr", related_rrn: nil)
        task.invoke
        expect(result.length).to eq(2)
      end
    end
  end
end
