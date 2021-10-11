describe UseCase::ImportEnums do
  context "when calling the use case to process the enums" do
    let(:use_case) do
      described_class.new(assessment_lookups_gateway: gateway, xsd_presenter: presenter, assessment_attribute_gateway: attribute_gateway)
    end

    let(:gateway) do
      instance_double(Gateway::AssessmentLookupsGateway)
    end

    let(:attribute_gateway) do
      instance_double(Gateway::AssessmentAttributesGateway)
    end

    let(:attribute_mappings) do
      JSON.parse(File.read("config/dev/attribute_enum_map.json"))
    end

    let(:presenter) do
      Presenter::Xsd.new
    end

    before do
      allow(gateway).to receive(:add_lookup).with(anything).and_return(1)
      allow(attribute_gateway).to receive(:get_attribute_id).and_return("1")

      allow(presenter).to receive(:get_enums_by_type).with(ViewModelDomain::XsdArguments.new(simple_type: "SAP-BuiltForm", assessment_type: "RdSap")).and_return(
        { "RdSap-18.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" },
          "RdSap-17.0.0" => { "1" => "a1", "2" => "b1", "3" => "c1", "nr" => "other1" } },
      )

      allow(presenter).to receive(:get_enums_by_type).with(ViewModelDomain::XsdArguments.new(simple_type: "Tranasction-Type", assessment_type: "RdSap")).and_return(
        { "RdSap-18.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" },
          "RdSap-17.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" } },
      )
    end

    it "can read json mapping" do
      expect(attribute_mappings).to be_a(Array)
      expect(attribute_mappings.length).to eq(2)
      expect(attribute_mappings.first).to match hash_including({ "attribute_name" => "built_form",
                                                                 "type_of_assessment" => "RdSap",
                                                                 "xsd_node_name" => "SAP-BuiltForm" })
    end

    it "receive the array and loop over it the correct number of times" do
      use_case.execute(attribute_mappings)
      expect(presenter).to have_received(:get_enums_by_type).exactly(2).times
      expect(gateway).to have_received(:add_lookup).exactly(12).times
    end
  end

  context "when calling the real Presenter" do
    let(:arguments) {
      [{
         "attribute_name" => "construction_age_band",
         "type_of_assessment" => "RdSAP",
         "xsd_node_name" => "blah"
       }
      ]
    }


    it 'the presenter raises an error which is bubbled up to the use case and rethrown' do
      use_case = described_class.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: Presenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new)
      expect{use_case.execute(arguments)}.to raise_error(ViewModelBoundary::NodeNotFound)

    end

  end
end
