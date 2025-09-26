describe UseCase::FetchLookups do
  subject(:use_case) do
    described_class.new(gateway:)
  end

  let(:expected) do
    %w[built_form construction_age_band cylinder_insulation_thickness]
  end
  let(:gateway) do
    instance_double(Gateway::AssessmentLookupsGateway)
  end

  before do
    allow(gateway).to receive(:fetch_lookups).and_return expected
  end

  describe "#execute" do
    it "returns the lookup data from the gateway" do
      expect(use_case.execute).to eq expected
    end

    it "calls the gateway only once" do
      use_case.execute
      expect(gateway).to have_received(:fetch_lookups).exactly(1).times
    end
  end
end
