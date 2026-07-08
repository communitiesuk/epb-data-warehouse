shared_context "when saving data for country_id rake" do
  def save_new_epc(schema:, assessment_id:, assessment_type:, sample_type:, country_id:, created_at: nil, postcode: nil)
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

    country_gateway = Gateway::AssessmentsCountryIdGateway.new
    country_gateway.insert(assessment_id:, country_id:) unless country_id.nil?

    Gateway::AssessmentSearchGateway.new.insert_assessment(assessment_id: assessment_id, document: parsed_epc, country_id: 1)
  end
end

describe "Backfill assessment_search country_id column rake" do
  let(:search) do
    ActiveRecord::Base.connection.exec_query(
      <<~SQL,
        SELECT s.assessment_id, s.country_id as country_id
        FROM assessment_search s
      SQL
    ).to_a
  end

  before do
    allow($stdout).to receive(:puts)
  end

  after do
    ENV.delete("START_DATE")
    ENV.delete("END_DATE")
  end

  context "when calling the rake task" do
    subject(:task) { get_task("one_off:backfill_assessment_search_country_id") }

    include_context "when saving data for country_id rake"

    before do
      save_new_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "SAP", sample_type: "epc", country_id: 1, created_at: Date.new(2022, 7, 14))
      save_new_epc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", assessment_type: "SAP", sample_type: "epc", country_id: 4, created_at: Date.new(2022, 7, 14))
      save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", assessment_type: "RdSAP", sample_type: "epc", country_id: 2, created_at: Date.new(2023, 7, 14))

      ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET country_id = NULL")
    end

    it "Country ids are populated" do
      task.invoke
      expect(search.find { |i| i["assessment_id"] == "0000-0000-0000-0000-0000" }["country_id"]).to eq(1)
      expect(search.find { |i| i["assessment_id"] == "5555-5555-5555-5555-5555" }["country_id"]).to eq(4)
      expect(search.find { |i| i["assessment_id"] == "0000-6666-4444-3333-2222" }["country_id"]).to eq(2)
    end

    it "shows a message of the assessments count to be backfilled" do
      expect { task.invoke }.to output(/Updated 3 rows in assessment_search/).to_stdout
    end

    context "when processing rows that already have a country_id value" do
      before do
        ActiveRecord::Base.connection.exec_query(
          "UPDATE assessment_search SET country_id = 5 WHERE assessment_id = '0000-6666-4444-3333-2222'",
        )
      end

      it "does not overwrite the existing value" do
        task.invoke
        expect(search.find { |i| i["assessment_id"] == "0000-6666-4444-3333-2222" }["country_id"]).to eq(5)
      end
    end

    context "when passing date ranges" do
      before do
        ENV["START_DATE"] = "2022-01-01"
        ENV["END_DATE"] = "2022-12-31"
      end

      after do
        ENV.delete("START_DATE")
        ENV.delete("END_DATE")
      end

      it "updates the rows within the range" do
        task.invoke
        expect(search.find { |i| i["assessment_id"] == "0000-0000-0000-0000-0000" }["country_id"]).to eq(1)
        expect(search.find { |i| i["assessment_id"] == "5555-5555-5555-5555-5555" }["country_id"]).to eq(4)
      end

      it "does not update the rows outside the date range" do
        task.invoke
        expect(search.find { |i| i["assessment_id"] == "0000-6666-4444-3333-2222" }["country_id"]).to be_nil
      end
    end

    context "when passing invalid date range" do
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
