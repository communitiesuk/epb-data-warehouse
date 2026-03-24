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
      [{ name: "Belfast", lower_name: "belfast" }, { name: "South Lanarkshire", lower_name: "south lanarkshire" }, { name: "Westminster", lower_name: "westminster" }, { name: "Hammersmith and Fulham", lower_name: "hammersmith and fulham" }]
    end

    it "returns an array of councils" do
      expect(gateway.councils.sort_by! { |i| i[:name] }).to eq(councils.sort_by! { |i| i[:name] })
    end
  end

  describe "constituencies" do
    let(:constituencies) do
      [{ name: "Belfast South", lower_name: "belfast south" }, { name: "Cities of London and Westminster", lower_name: "cities of london and westminster" }, { name: "Lanark and Hamilton East", lower_name: "lanark and hamilton east" }, { name: "Bury St Edmunds and Stowmarket", lower_name: "bury st edmunds and stowmarket" }, { name: "Chelsea and Fulham", lower_name: "chelsea and fulham" }]
    end

    it "returns an array of constituencies" do
      expect(gateway.constituencies.sort_by! { |i| i[:name] }).to eq(constituencies.sort_by! { |i| i[:name] })
    end
  end
end
