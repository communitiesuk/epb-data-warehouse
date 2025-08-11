describe UseCase::CountCertificates do
  subject(:use_case) do
    described_class.new(assessment_search_gateway:)
  end

  let(:assessment_search_gateway) do
    instance_double(Gateway::AssessmentSearchGateway)
  end

  let(:search_arguments) do
    { date_start: "2023-12-01", date_end: "2023-12-23", council_id: nil }
  end

  let(:expectation) do
    20
  end

  before do
    allow(assessment_search_gateway).to receive_messages(count: 20)
  end

  it "can call the use case" do
    expect { use_case.execute(**search_arguments) }.not_to raise_error
  end

  it "passes the arguments to the gateway to count domestic data" do
    expect(use_case.execute(**search_arguments)).to eq expectation
    expect(assessment_search_gateway).to have_received(:count).with(search_arguments).exactly(1).times
  end

  context "when a council name is provided" do
    let(:args) do
      { date_start: "2023-12-01", date_end: "2023-12-23", council_id: 1 }
    end

    before do
      args[:council] = "Hammersmith and Fulham"
      use_case.execute(**args)
    end

    it "passes the council id to the search" do
      expect(assessment_search_gateway).to have_received(:count).with(args).exactly(1).times
    end
  end

  context "when all the efficiency ratings are provided" do
    let(:args) do
      { date_start: "2023-12-01", date_end: "2023-12-23", eff_rating: %w[A B C D E F G] }
    end

    before do
      use_case.execute(**args)
    end

    it "doesn't pass any efficiency rating to the search" do
      args.delete(:eff_rating)
      expect(assessment_search_gateway).to have_received(:count).with(args).exactly(1).times
    end
  end
end
