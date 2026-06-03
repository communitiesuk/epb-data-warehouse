shared_context "when saving data for schema_type rake" do
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

describe "running assessment_search.schema_type rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:backfill_assessment_search_schema_type") }

    include_context "when saving data for schema_type rake"

    let(:search) do
      ActiveRecord::Base.connection.exec_query(
        <<~SQL,
          SELECT s.assessment_id, s.schema_type as search_schema_type, d.document ->> 'schema_type' as doc_schema_type
          FROM assessment_search s
          JOIN assessment_documents d ON s.assessment_id = d.assessment_id
        SQL
      ).to_a
    end

    before do
      allow($stdout).to receive(:puts)
    end

    after do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_search;")
    end

    context "when certificates exist in the database" do
      before do
        save_new_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "SAP", sample_type: "epc")
        save_new_epc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", assessment_type: "SAP", sample_type: "epc")
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", assessment_type: "RdSAP", sample_type: "epc")

        ActiveRecord::Base.connection.exec_query(
          "UPDATE assessment_search SET schema_type = NULL WHERE assessment_id IN ('0000-0000-0000-0000-0000', '5555-5555-5555-5555-5555')",
        )
      end

      it "does not raise an error" do
        expect { task.invoke }.not_to raise_error
      end

      context "when processing rows with a NULL schema_type" do
        it "updates the rows by extracting the value from the JSONB document" do
          task.invoke

          search.each do |row|
            expect(row["search_schema_type"]).to eq(row["doc_schema_type"])
            expect(row["search_schema_type"]).not_to be_nil
          end
        end

        it "shows a message of the assessments count to be backfilled" do
          expect { task.invoke }.to output(/Updated 2 rows in assessment_search/).to_stdout
        end
      end

      context "when processing rows that already have a schema_type value" do
        before do
          ActiveRecord::Base.connection.exec_query(
            "UPDATE assessment_search SET schema_type = 'Fake-Schema-1.0' WHERE assessment_id = '0000-6666-4444-3333-2222'",
          )
        end

        it "does not overwrite the existing value" do
          task.invoke

          row = search.find { |i| i["assessment_id"] == "0000-6666-4444-3333-2222" }

          expect(row["search_schema_type"]).not_to eq(row["doc_schema_type"])
          expect(row["search_schema_type"]).to eq("Fake-Schema-1.0")
        end
      end
    end

    context "when passing date ranges" do
      before do
        ENV["START_DATE"] = "2022-01-01"
        ENV["END_DATE"] = "2022-12-31"
        save_new_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "SAP", sample_type: "epc", created_at: Date.new(2022, 7, 14))
        save_new_epc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", assessment_type: "SAP", sample_type: "epc", created_at: Date.new(2022, 7, 14))
        save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", assessment_type: "RdSAP", sample_type: "epc", created_at: Date.new(2023, 7, 14))

        ActiveRecord::Base.connection.exec_query(
          "UPDATE assessment_search SET schema_type = NULL",
        )
      end

      after do
        ENV.delete("START_DATE")
        ENV.delete("END_DATE")
      end

      it "updates the rows within the range" do
        task.invoke

        row = search.find { |i| i["assessment_id"] == "0000-0000-0000-0000-0000" }
        expect(row["search_schema_type"]).to eq(row["doc_schema_type"])

        row = search.find { |i| i["assessment_id"] == "5555-5555-5555-5555-5555" }
        expect(row["search_schema_type"]).to eq(row["doc_schema_type"])
      end

      it "does not update the rows outside the date range" do
        task.invoke

        row = search.find { |i| i["assessment_id"] == "0000-6666-4444-3333-2222" }
        expect(row["search_schema_type"]).to be_nil
      end

      it "raises an error if only one date is given" do
        ENV["START_DATE"] = "2023-05-01"
        ENV.delete("END_DATE")
        expect { task.invoke }.to raise_error(Boundary::ArgumentMissing).with_message("A required argument is missing: END_DATE")
      end

      it "raises an error if invalid dates are given" do
        ENV["START_DATE"] = "not a date"
        ENV["END_DATE"] = "2024-05-01"
        expect { task.invoke }.to raise_error ArgumentError
      end

      it "raises an error if the date range is not valid" do
        ENV["START_DATE"] = "2025-05-01"
        ENV["END_DATE"] = "2023-05-01"
        expect { task.invoke }.to raise_error ArgumentError
      end

      it "does not raise an error if the date range is the same day" do
        ENV["START_DATE"] = "2023-05-01"
        ENV["END_DATE"] = "2023-05-01"
        expect { task.invoke }.not_to raise_error
      end
    end
  end
end
