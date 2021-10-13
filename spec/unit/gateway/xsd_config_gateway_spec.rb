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

  it "produces a hash of paths " do
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
end
