require_relative "../../shared_context/shared_ons_data"

describe Gateway::OnsPostcodeDirectoryNamesGateway do
  subject(:gateway) { described_class.new }

  include_context "when saving ons data"

  describe "#init" do
    it "can be initialized" do
      expect { gateway }.not_to raise_error
    end
  end

  describe "#fetch_council_id" do
    before do
      import_postcode_directory_name
    end

    it "returns an integer for the council name" do
      expect(gateway.fetch_council_id("Hammersmith and Fulham")).to eq 1
    end
  end
end
