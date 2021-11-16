RSpec.describe "the parser and the rdsap configuration" do
  context "when loading xml from RdSap" do
    let(:config) do
      XmlPresenter::Cepc::Cepc800ExportConfiguration.new
    end

    let(:parser) do
      XmlPresenter::Parser.new(specified_report: { root_node: "Report", sub_node: "RRN", sub_node_value: "0000-0000-0000-0000-0000" }, **config.to_args)
    end

    let(:cepc) do
      Samples.xml("CEPC-8.0.0", "cepc")
    end

    it "doesn't error" do
      expect { parser.parse(sap) }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = {'Boop' => 'Bing'}
      pp parser.parse(cepc)
      expect(parser.parse(cepc)).to eq(expectation)
    end
  end
end
