describe UseCase::ImportEnums do
  let(:use_case) do
    described_class.new(assessment_lookups_gateway: gateway, xsd_presenter: presenter, assessment_attribute_gateway: attribute_gateway, xsd_config_gateway: xsd_config_gateway)
  end

  let(:gateway) do
    instance_double(Gateway::AssessmentLookupsGateway)
  end

  let(:attribute_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end

  let(:xsd_config_gateway) do
    Gateway::XsdConfigGateway.new("spec/config/attribute_enum_map.json")
  end

  let(:presenter) do
    Presenter::Xsd.new
  end

  context "when calling the use case to process the enums" do
    before do
      allow(gateway).to receive(:add_lookup).with(anything).and_return(1)
      allow(attribute_gateway).to receive(:get_attribute_id).and_return("1")

      allow(presenter).to receive(:get_enums_by_type).and_return(
        { "RdSap-18.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" },
          "RdSap-17.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" } },
      )

      allow(presenter).to receive(:get_enums_by_type).and_return(
        { "RdSap-18.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" },
          "RdSap-17.0.0" => { "1" => "a1", "2" => "b1", "3" => "c1", "nr" => "other1" } },
      )
    end
  end

  context "when receiving enums that have variations between schema versions for an attribute" do
    before do
      allow(gateway).to receive(:add_lookup).with(anything).and_return(1)
      allow(attribute_gateway).to receive(:add_attribute).and_return("1")

      allow(presenter).to receive(:get_enums_by_type).and_return(
        { "RdSap-18.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" },
          "RdSap-17.0.0" => { "1" => "a1", "2" => "b1", "3" => "c1", "nr" => "other1" } },
      )
    end

    let(:attribute_mappings) do
      [
        {
          "attribute_name" => "tranasction_type",
          "type_of_assessment" => "RdSap",
          "xsd_node_name" => "Tranasction-Type",
        },
      ]
    end

    it "receive the array and loop over it the correct number of times" do
      use_case.execute
      expect(presenter).to have_received(:get_enums_by_type).exactly(2).times
      expect(gateway).to have_received(:add_lookup).exactly(16).times
    end
  end

  context "when receiving enums that have no variations between schema versions for an attribute" do
    before do
      allow(xsd_config_gateway).to receive(:nodes_and_paths).and_return([{
        "attribute_name" => "construction_age_band",
        "type_of_assessment" => "RdSAP",
        "xsd_node_name" => "test",
        "xsd_path" => "/api/schemas/xml/RdSAP**/RdSAP/UDT/*-Domains.xsd",
      }])
      allow(gateway).to receive(:add_lookup).with(anything).and_return(1)
      allow(attribute_gateway).to receive(:add_attribute).and_return("1")
      allow(presenter).to receive(:get_enums_by_type).and_return(
        { "RdSap-18.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" },
          "RdSap-17.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" } },
      )
    end

    it "receive the array and loop over it 4 times - once for each unique key" do
      use_case.execute
      expect(presenter).to have_received(:get_enums_by_type).exactly(1).times
      expect(gateway).to have_received(:add_lookup).exactly(4).times
    end
  end

  context "when calling the real presenter" do
    let(:arguments) do
      [{
        "attribute_name" => "construction_age_band",
        "type_of_assessment" => "RdSAP",
        "xsd_node_name" => "blah",
        "xsd_path" => "/api/schemas/xml/RdSAP**/RdSAP/UDT/*-Domains.xsd",
      }]
    end

    let(:xsd_config) do
      instance_double(Gateway::XsdConfigGateway)
    end

    let(:use_case) do
      described_class.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new,
                          xsd_presenter: Presenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: xsd_config)
    end

    before do
      allow(xsd_config).to receive(:nodes_and_paths).and_return(arguments)
    end

    it "the presenter raises an error which is bubbled up to the use case and rethrown" do
      expect { use_case.execute }.to raise_error(ViewModelBoundary::NodeNotFound)
    end

    xit "extracts construction age band and save the data with all the variations" do
      arguments.first["xsd_node_name"] = "ConstructionDateCode"
      # use_case.execute(arguments)
    end
  end
end
