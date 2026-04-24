shared_context "when saving data for created_at rake" do
  def save_new_epc(schema:, assessment_id:, assessment_type:, sample_type:, country_id: 1, created_at: nil, postcode: nil)
    sample = Samples.xml(schema, sample_type)
    use_case = UseCase::ParseXmlCertificate.new
    parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id:)
    parsed_epc["assessment_id"] = assessment_id
    parsed_epc["assessment_type"] = assessment_type
    parsed_epc["schema_type"] = schema
    parsed_epc["registration_date"] = created_at.to_s unless created_at.nil?
    parsed_epc["postcode"] = postcode unless postcode.nil?
    parsed_epc["assessment_address_id"] = "UPRN-1000000001245"
    parsed_epc["created_at"] = Time.parse("2025-12-20T09:54:32.000Z")
    import = Gateway::DocumentsGateway.new
    import.add_assessment(assessment_id:, document: parsed_epc)
    country_gateway = Gateway::AssessmentsCountryIdGateway.new
    country_gateway.insert(assessment_id:, country_id:) unless country_id.nil?
    Gateway::AssessmentSearchGateway.new.insert_assessment(assessment_id: assessment_id, document: parsed_epc, country_id: 1)
  end
end

require_relative "../shared_context/shared_lodgement"
describe "running assessment_search.created_at rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:fix_assessment_search_created_at") }

    include_context "when saving data for created_at rake"
    after do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_attribute_values;")
    end

    context "when certificates are updated" do
      before do
        save_new_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "SAP", sample_type: "epc")
        save_new_epc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", assessment_type: "SAP", sample_type: "epc")
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", assessment_type: "RdSAP", sample_type: "epc")
      end

      let(:search) do
        ActiveRecord::Base.connection.exec_query(
          "SELECT s.assessment_id, created_at::timestamptz as created_at, (document ->> 'created_at')::timestamptz as doc_created_at
                    FROM assessment_search s JOIN assessment_documents d ON s.assessment_id = d.assessment_id",
        ).map { |row| row }
      end

      it "does not raise an error" do
        expect { task.invoke }.not_to raise_error
      end

      context "when the rows that do not have matching created_at values" do
        before do
          ActiveRecord::Base.connection.exec_query(
            "UPDATE assessment_search SET created_at = '#{Time.now}'  WHERE assessment_id IN ('0000-0000-0000-0000-0000', '5555-5555-5555-5555-5555')",
          )
        end

        it "updates all rows" do
          task.invoke
          search.each do |row|
            expect(row["created_at"].to_s).to eq row["doc_created_at"].to_s
          end
        end
      end

      context "when running a rows before the filter date are not processed" do
        before do
          save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2224", assessment_type: "RdSAP", sample_type: "epc")
          ActiveRecord::Base.connection.exec_query(
            "UPDATE assessment_search SET created_at = '2025-03-20T09:54:32.000Z'  WHERE assessment_id = '0000-6666-4444-3333-2224'",
          )
        end

        it "the row is out out date is not updated" do
          task.invoke
          row = search.find { |i| i["assessment_id"] == "0000-6666-4444-3333-2224" }
          expect(row["created_at"].to_s).not_to eq row["doc_created_at"].to_s
        end
      end
    end
  end
end
