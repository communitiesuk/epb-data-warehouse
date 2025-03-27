require_relative "../../shared_context/shared_ons_data"

describe Gateway::OnsPostcodeDirectoryNamesGateway do
  subject(:gateway) { described_class.new }

  include_context "when saving ons data"

  describe "#init" do
    it "can be initialized" do
      expect { gateway }.not_to raise_error
    end
  end
end
