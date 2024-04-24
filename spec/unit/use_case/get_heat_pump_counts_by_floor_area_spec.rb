describe UseCase::GetHeatPumpCountsByFloorArea do
  let(:export_gateway) do
    instance_double(Gateway::ExportHeatPumpsGateway)
  end

  let(:use_case) do
    described_class.new(export_gateway:)
  end

  describe "#execute" do
    let(:data) do
      [{ "total_floor_area" => "BETWEEN 0 AND 50", "number_of_assessments" => 1 },
       { "total_floor_area" => "BETWEEN 101 AND 150", "number_of_assessments" => 2 },
       { "total_floor_area" => "BETWEEN 151 AND 200", "number_of_assessments" => 1 },
       { "total_floor_area" => "BETWEEN 201 AND 250", "number_of_assessments" => 1 },
       { "total_floor_area" => "BETWEEN 51 AND 100", "number_of_assessments" => 1 },
       { "total_floor_area" => "GREATER THAN 251", "number_of_assessments" => 1 }]
    end

    let(:args) do
      {
        start_date: "2023-01-01",
        end_date: "2023-01-31",
      }
    end

    let(:expected_data) do
      {
        between_0_and_50: 1,
        between_101_and_150: 2,
        between_151_200: 1,
        between_201_250: 1,
        between_51_100: 1,
        greater_than_251: 1,
      }
    end

    before do
      allow(export_gateway).to receive(:fetch_by_floor_area).and_return data
    end

    it "calls the gateway" do
      use_case.execute(**args)
      expect(export_gateway).to have_received(:fetch_by_floor_area).with(start_date: "2023-01-01", end_date: "2023-01-31").exactly(1).times
    end

    it "returns the data" do
      expect(use_case.execute(**args)).to eq(expected_data)
    end
  end
end
