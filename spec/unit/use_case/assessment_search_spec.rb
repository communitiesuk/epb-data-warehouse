describe UseCase::AssessmentSearch do
  subject(:use_case) do
    described_class.new(assessment_search_gateway:)
  end

  let(:assessment_search_gateway) do
    instance_double(Gateway::AssessmentSearchGateway)
  end

  let(:search_arguments) do
    { date_start: "2023-12-01", date_end: "2023-12-23" }
  end

  let(:assessment_search_result) do
    [{
      "certificate_number" => "0000-0000-0000-0000",
      "address_line_1" => "1 Some Street",
      "address_line_2" => nil,
      "address_line_3" => nil,
      "address_line_4" => nil,
      "assessment_address_id" => "RRN-0000-0000-0000-0000-0000",
      "constituency" => "Chelsea and Fulham",
      "council" => "Hammersmith and Fulham",
      "current_energy_efficiency_band" => "E",
      "post_town" => "Whitbury",
      "postcode" => "SW10 0AA",
      "registration_date" => Date.new(2020, 5, 4),
    }]
  end

  before do
    allow(assessment_search_gateway).to receive(:fetch_assessments).and_return(assessment_search_result)
  end

  it "can call the use case" do
    expect { use_case.execute(**search_arguments) }.not_to raise_error
  end

  it "passes the arguments to the assessment_search_gateway" do
    use_case.execute(**search_arguments)
    expect(assessment_search_gateway).to have_received(:fetch_assessments).with(**search_arguments).exactly(1).times
  end

  it "returns the response produced by the gateway" do
    expect(use_case.execute(**search_arguments)).to eq assessment_search_result
  end

  context "when all eff_ratings parameters are provided" do
    it "does not pass them to the gateway" do
      eff_rating_arguments = search_arguments.merge({ eff_rating: %w[A B C D E F G] })
      use_case.execute(**eff_rating_arguments)
      expect(assessment_search_gateway).to have_received(:fetch_assessments).with(**search_arguments).exactly(1).times
    end
  end
end
