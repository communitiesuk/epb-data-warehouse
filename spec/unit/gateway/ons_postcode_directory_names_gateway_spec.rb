require_relative "../../shared_context/shared_ons_data"

describe Gateway::OnsPostcodeDirectoryNamesGateway do
  subject(:gateway) { described_class.new }

  include_context "when saving ons data"

  describe "#init" do
    it "can be initialized" do
      expect { gateway }.not_to raise_error
    end
  end

  describe "councils" do
    let(:councils) do
      ["Hammersmith and Fulham", "South Lanarkshire", "Belfast", "Westminster"]
    end

    it "returns a list of councils" do
      expect(gateway.councils.map { |i| i["name"] }).to eq councils
    end
  end

  describe "constituencies" do
    let(:constituencies) do
      ["Belfast South", "Chelsea and Fulham", "Lanark and Hamilton East", "Cities of London and Westminster"]
    end

    it "returns a list of councils" do
      expect(gateway.constituencies.map { |i| i["name"] }).to eq constituencies
    end
  end
end
