describe Gateway::AssessmentsCountryIdGateway do
  let(:gateway) { described_class.new }

  before do
    Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.delete_all
  end

  describe "#insert" do
    it "saves the row to the table" do
      assessment_id = "0000-0000-0001-1234-0000"
      country_id = 5
      gateway.insert(assessment_id:, country_id:)
      row = described_class::AssessmentsCountryId.find_by(assessment_id:)
      expect(row.country_id).to eq 5
    end
  end

  describe "#delete_assessment" do
    let(:assessment_id) { "0000-0000-0001-1234-0000" }

    before do
      country_id = 5
      gateway.insert(assessment_id:, country_id:)
      country_id = 1
      gateway.insert(assessment_id: "0000-0000-0001-1234-0001", country_id:)
    end

    it "removed the correct row from the table" do
      expect(Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.count).to eq 2
      gateway.delete_assessment(assessment_id:)
      expect(Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.count).to eq 1
      expect(Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.find_by(assessment_id: "0000-0000-0001-1234-0000")).to be_nil
    end
  end
end
