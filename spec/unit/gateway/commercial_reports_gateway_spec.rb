describe Gateway::CommercialReportsGateway do
  subject(:gateway) { described_class.new }

  let(:commercial_reports_result) do
    ActiveRecord::Base.connection.exec_query(
      "SELECT * FROM commercial_reports",
    )
  end

  let(:assessment_id) { "0000-0000-0000-0000-1111" }
  let(:related_rrn) { "0000-0000-0000-0000-2222" }

  describe "#insert_report" do
    before do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
    end

    context "when saving a report" do
      before do
        gateway.insert_report(assessment_id:, related_rrn:)
      end

      it "saves the row to the table" do
        expect(commercial_reports_result.length).to eq 1
        expect(commercial_reports_result.first["assessment_id"]).to eq "0000-0000-0000-0000-1111"
      end

      it "has the correct related_rrn" do
        expect(commercial_reports_result.first["related_rrn"]).to eq "0000-0000-0000-0000-2222"
      end
    end

    context "when the assessment_id already exists" do
      before do
        gateway.insert_report(assessment_id:, related_rrn:)
      end

      it "does not raise an error" do
        expect { gateway.insert_report(assessment_id:, related_rrn: "0000-0000-0000-0000-1115") }.not_to raise_error
      end
    end
  end
end
