describe Gateway::AssessmentsAddressIdGateway do
  let(:gateway) { described_class.new }
  let(:count) do
    sql = "SELECT * FROM assessments_address_id"
    ActiveRecord::Base.connection.exec_query(sql).rows.length
  end

  before do
    ActiveRecord::Base.connection.execute("TRUNCATE assessments_address_id")
  end

  def fetch_row(assessment_id)
    sql = "SELECT * FROM assessments_address_id WHERE assessment_id ='#{assessment_id}'"
    result = ActiveRecord::Base.connection.exec_query(sql)
    result.first&.symbolize_keys
  end

  describe "#insert_or_update_address_id" do
    let(:assessment_id) { "0000-0000-0001-1234-0000" }

    context "when inserting a row that does not exist" do
      it "inserts a new row with address_id" do
        gateway.insert_or_update_address_id(assessment_id:, address_id: "UPRN-10000000001")

        row = fetch_row(assessment_id)

        expect(row).not_to be_nil
        expect(row[:address_id]).to eq "UPRN-10000000001"
        expect(row[:matched_uprn]).to be_nil
      end
    end

    context "when updating an existing row" do
      before do
        gateway.insert_or_update_matched_uprn(assessment_id:, matched_uprn: "3000000001")
      end

      it "updates address_id without overwriting matched_uprn" do
        gateway.insert_or_update_address_id(assessment_id:, address_id: "UPRN-10000000002")

        row = fetch_row(assessment_id)

        expect(row[:address_id]).to eq "UPRN-10000000002"
        expect(row[:matched_uprn]).to eq 3_000_000_001
      end
    end

    context "when inserting twice the same data" do
      before do
        gateway.insert_or_update_address_id(assessment_id:, address_id: "UPRN-10000000001")
      end

      it "does not create duplicate rows" do
        gateway.insert_or_update_address_id(assessment_id:, address_id: "UPRN-10000000001")
        expect(count).to eq 1
      end
    end
  end

  describe "#insert_or_update_matched_uprn" do
    let(:assessment_id) { "0000-0000-0001-1234-0001" }

    context "when inserting a row that does not exist" do
      it "inserts a new row with matched_uprn" do
        gateway.insert_or_update_matched_uprn(assessment_id:, matched_uprn: "3000000002")

        row = fetch_row(assessment_id)

        expect(row).not_to be_nil
        expect(row[:matched_uprn]).to eq 3_000_000_002
        expect(row[:address_id]).to be_nil
      end
    end

    context "when updating an existing row" do
      before do
        gateway.insert_or_update_address_id(assessment_id:, address_id: "UPRN-10000000005")
      end

      it "updates matched_uprn without overwriting address_id" do
        gateway.insert_or_update_matched_uprn(assessment_id:, matched_uprn: "3000000007")

        row = fetch_row(assessment_id)

        expect(row[:matched_uprn]).to eq 3_000_000_007
        expect(row[:address_id]).to eq "UPRN-10000000005"
      end
    end

    context "when inserting twice the same data" do
      before do
        gateway.insert_or_update_matched_uprn(assessment_id:, matched_uprn: "3000000002")
      end

      it "does not create duplicate rows" do
        gateway.insert_or_update_matched_uprn(assessment_id:, matched_uprn: "3000000002")
        expect(count).to eq 1
      end
    end
  end
end
