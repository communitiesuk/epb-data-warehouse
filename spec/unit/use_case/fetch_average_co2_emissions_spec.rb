describe UseCase::FetchAverageCo2Emissions do
  subject(:use_case) do
    described_class.new(gateway:)
  end

  let(:gateway) do
    instance_double(Gateway::AverageCo2EmissionsGateway)
  end

  let(:expected_values) do
    [
      { "avg_co2_emission" => 10.0, "country" => "Northern Ireland", "year_month" => "2022-03" },
      { "avg_co2_emission" => 15.0, "country" => "England", "year_month" => "2022-04" },
      { "avg_co2_emission" => 10.0, "country" => "England", "year_month" => "2022-05" },
    ]
  end

  before do
    allow(gateway).to receive(:fetch).and_return(expected_values)
  end

  it "fetches the average co2 emissions" do
    expect(use_case.execute).to eq expected_values
  end
end
