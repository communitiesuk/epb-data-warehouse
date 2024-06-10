describe Gateway::AssessmentsCountryIdGateway do
  let(:gateway) { described_class.new }

  describe "#insert" do
    it "saves the row to the table" do
      assessment_id = "0000-0000-0001-1234-0000"
      country_id = 5
      gateway.insert(assessment_id:, country_id:)
      row = described_class::AssessmentsCountryId.find_by(assessment_id:)
      expect(row.country_id).to eq 5
    end
  end

  describe "#delete" do
    let(:assessment_id) { "0000-0000-0001-1234-0000" }

    before do
      country_id = 5
      gateway.insert(assessment_id:, country_id:)
    end

    it "removed the row to the table" do
      expect { gateway.delete(assessment_id:) }.not_to raise_error
      expect(Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.count).to eq 0
    end
  end
end
