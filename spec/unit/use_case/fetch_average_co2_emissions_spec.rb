describe UseCase::FetchAverageCo2Emissions do
  subject(:use_case) do
    described_class.new(gateway:)
  end

  let(:gateway) do
    instance_double(Gateway::AverageCo2EmissionsGateway)
  end

  let(:fetch_values) do
    [
      { "avg_co2_emission" => 10, "country" => "Northern Ireland", "year_month" => "2022-03" },
      { "avg_co2_emission" => 15, "country" => "England", "year_month" => "2022-04" },
      { "avg_co2_emission" => 10, "country" => "England", "year_month" => "2022-05" },
    ]
  end

  let(:fetched_all_values) do
    [
      { "avg_co2_emission" => 9,  "year_month" => "2022-03" },
      { "avg_co2_emission" => 25,  "year_month" => "2022-04" },
      { "avg_co2_emission" => 45,  "year_month" => "2022-05" },
    ]
  end

  let(:expected_values) do
    { all: fetched_all_values,
      england: [{ "avg_co2_emission" => 15, "country" => "England", "year_month" => "2022-04" }, { "avg_co2_emission" => 10, "country" => "England", "year_month" => "2022-05" }],
      northern_ireland: [{ "avg_co2_emission" => 10, "country" => "Northern Ireland", "year_month" => "2022-03" }] }
  end

  before do
    allow(gateway).to receive_messages(fetch: fetch_values, fetch_all: fetched_all_values)
  end

  it "fetches the average co2 emissions" do
    expect(use_case.execute).to eq expected_values
  end
end
