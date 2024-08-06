describe Gateway::XsdConfigGateway do
  let(:gateway) { described_class.new("spec/config/attribute_enum_map.json") }

  it "loads the config without raising an error" do
    expect { gateway }.not_to raise_error
  end

  it "produces a hash of attributes nodes" do
    expect(gateway.nodes).to be_a(Array)
    expect(gateway.nodes.length).to eq(2)
    expect(gateway.nodes.first).to match hash_including({ "attribute_name" => "built_form",
                                                          "type_of_assessment" => "RdSap",
                                                          "xsd_node_name" => "SAP-BuiltForm" })
  end

  it "produces a hash of attributes nodes containing a hash of xml nodes" do
    expected = { "attribute_name" => "transaction_type",
                 "type_of_assessment" => "SAP",
                 "xsd_node_name" => "Transaction-Type",
                 "node_hash" => { "Transaction-Code" => "Transaction-Text" } }

    expect(gateway.nodes.last).to match hash_including(expected)
  end

  it "produces a hash of paths" do
    expect(gateway.paths).to match hash_including({ "rdsap" => "/api/schemas/xml/RdSAP**/RdSAP/UDT/*-Domains.xsd",
                                                    "sap" => "/api/schemas/xml/SAP**/SAP/UDT/*-Domains.xsd",
                                                    "cepc" => "/api/schemas/xml/CEPC**/Reports/Reported-Data.xsd" })
  end

  describe "#nodes_and_paths" do
    let(:nodes_with_paths) do
      gateway.nodes_and_paths
    end

    it "produces a hash that combines the node with the relevant xsd paths based on the type_of_assessment" do
      expect(nodes_with_paths.detect { |a| a["type_of_assessment"] == "RdSap" }["xsd_path"]).to eq("/api/schemas/xml/RdSAP**/RdSAP/UDT/*-Domains.xsd")
      expect(nodes_with_paths.detect { |a| a["type_of_assessment"] == "SAP" }["xsd_path"]).to eq("/api/schemas/xml/SAP**/SAP/UDT/*-Domains.xsd")
    end
  end

  context "when the attribute hash contains an existing xsd_path" do
    let(:nodes) do
      [
        {
          "attribute_name" => "built_form",
          "type_of_assessment" => "RdSAP",
          "xsd_node_name" => "SAP-BuiltForm",
          "xsd_path" => "test/path",
        },
        {
          "attribute_name" => "construction",
          "type_of_assessment" => "RdSAP",
          "xsd_node_name" => "SAP-BuiltForm",
        },
      ]
    end

    let(:return_hash) do
      [
        {
          "attribute_name" => "built_form",
          "type_of_assessment" => "RdSAP",
          "xsd_node_name" => "SAP-BuiltForm",
          "xsd_path" => "test/path",
        },
        {
          "attribute_name" => "construction",
          "type_of_assessment" => "RdSAP",
          "xsd_node_name" => "SAP-BuiltForm",
          "xsd_path" => "/api/schemas/xml/RdSAP**/RdSAP/UDT/*-Domains.xsd",
        },
      ]
    end

    before do
      allow(gateway).to receive_messages(nodes:, paths: { "rdsap" => "/api/schemas/xml/RdSAP**/RdSAP/UDT/*-Domains.xsd",
                                                          "sap" => "/api/schemas/xml/SAP**/SAP/UDT/*-Domains.xsd",
                                                          "cepc" => "/api/schemas/xml/CEPC**/Reports/Reported-Data.xsd" })
    end

    it "preserves the xsd_path attribute and is not overwritten by the values from the path hash" do
      expect(gateway.nodes_and_paths).to eq(return_hash)
    end
  end

  context "when loading the production json file" do
    let(:prod_gateway) { described_class.new("config/attribute_enum_map.json") }

    it "does not raise an error due the the json being mistyped" do
      expect { prod_gateway }.not_to raise_error
    end
  end
end
