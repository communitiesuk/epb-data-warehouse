describe Domain::HeatPumpCountByFloorArea do
  context "when there are values for each range" do
    let(:data) do
      {
        "BETWEEN 0 AND 50" => 1,
        "BETWEEN 101 AND 150" => 2,
        "BETWEEN 151 AND 200" => 1,
        "BETWEEN 201 AND 250" => 1,
        "BETWEEN 51 AND 100" => 1,
        "GREATER THAN 251" => 1,
      }
    end

    let(:expected_result) do
      {
        between_0_and_50: 1,
        between_101_and_150: 2,
        between_151_200: 1,
        between_201_250: 1,
        between_51_100: 1,
        greater_than_251: 1,
      }
    end

    let(:domain) { described_class.new(data) }

    describe "#to_hash" do
      it "returns the expected result" do
        expect(domain.to_hash).to eq expected_result
      end
    end
  end

  context "when some values are empty" do
    let(:data) do
      {
        "BETWEEN 0 AND 50" => 1,
        "BETWEEN 101 AND 150" => 2,
        "BETWEEN 151 AND 200" => 1,
      }
    end

    let(:expected_result) do
      {
        between_0_and_50: 1,
        between_101_and_150: 2,
        between_151_200: 1,
        between_201_250: 0,
        between_51_100: 0,
        greater_than_251: 0,
      }
    end

    let(:domain) { described_class.new(data) }

    describe "#to_hash" do
      it "returns the expected result" do
        expect(domain.to_hash).to eq expected_result
      end
    end
  end
end
