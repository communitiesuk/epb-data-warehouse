describe UseCase::FetchLookupValues do
  subject(:use_case) do
    described_class.new(gateway:)
  end

  let(:data) do
    [{ "key" => "1", "value" => "Detached", "schema_version" => "RdSAP-Schema-21.0.1" },
     { "key" => "2", "value" => "Semi-Detached", "schema_version" => "RdSAP-Schema-21.0.1" },
     { "key" => "3", "value" => "End-Terrace", "schema_version" => "RdSAP-Schema-21.0.1" },
     { "key" => "4", "value" => "Mid-Terrace", "schema_version" => "RdSAP-Schema-21.0.1" },
     { "key" => "5", "value" => "Enclosed End-Terrace", "schema_version" => "RdSAP-Schema-21.0.1" },
     { "key" => "6", "value" => "Enclosed Mid-Terrace", "schema_version" => "RdSAP-Schema-21.0.1" },
     { "key" => "NR", "value" => "Not Recorded", "schema_version" => "RdSAP-Schema-21.0.1" },
     { "key" => "1", "value" => "Detached", "schema_version" => "SAP-Schema-19.0.0" },
     { "key" => "2", "value" => "Semi-Detached", "schema_version" => "SAP-Schema-19.0.0" },
     { "key" => "3", "value" => "End-Terrace", "schema_version" => "SAP-Schema-19.0.0" },
     { "key" => "4", "value" => "Mid-Terrace", "schema_version" => "SAP-Schema-19.0.0" },
     { "key" => "5", "value" => "Enclosed End-Terrace", "schema_version" => "SAP-Schema-19.0.0" },
     { "key" => "6", "value" => "Enclosed Mid-Terrace", "schema_version" => "SAP-Schema-19.0.0" }]
  end

  let(:expected) do
    [{ key: "1",
       values: [{ value: "Detached", schema_version: "RdSAP-Schema-21.0.1" },
                { value: "Detached", schema_version: "SAP-Schema-19.0.0" }] },
     { key: "2",
       values: [{ value: "Semi-Detached", schema_version: "RdSAP-Schema-21.0.1" },
                { value: "Semi-Detached", schema_version: "SAP-Schema-19.0.0" }] },
     { key: "3",
       values: [{ value: "End-Terrace", schema_version: "RdSAP-Schema-21.0.1" },
                { value: "End-Terrace", schema_version: "SAP-Schema-19.0.0" }] },
     { key: "4",
       values: [{ value: "Mid-Terrace", schema_version: "RdSAP-Schema-21.0.1" },
                { value: "Mid-Terrace", schema_version: "SAP-Schema-19.0.0" }] },
     { key: "5", values: [{ value: "Enclosed End-Terrace", schema_version: "RdSAP-Schema-21.0.1" }, { value: "Enclosed End-Terrace", schema_version: "SAP-Schema-19.0.0" }] },
     { key: "6", values: [{ value: "Enclosed Mid-Terrace", schema_version: "RdSAP-Schema-21.0.1" }, { value: "Enclosed Mid-Terrace", schema_version: "SAP-Schema-19.0.0" }] },
     { key: "NR", values: [{ value: "Not Recorded", schema_version: "RdSAP-Schema-21.0.1" }] }]
  end

  let(:gateway) do
    instance_double(Gateway::AssessmentLookupsGateway)
  end

  describe "#execute" do
    before do
      allow(gateway).to receive(:fetch_lookups_values).and_return data
    end

    context "when searching for lookup values by name" do
      it "extracts the data from the gateway" do
        use_case.execute(name: "built_form")
        expect(gateway).to have_received(:fetch_lookups_values).with(name: "built_form", schema_version: nil, lookup_key: nil)
      end

      it "the result has been formatted by the domain" do
        expect(use_case.execute(name: "built_form")).to eq(expected)
      end
    end

    context "when searching for lookup values by name and lookup_key" do
      it "extracts the data from the gateway" do
        use_case.execute(name: "built_form", lookup_key: "1")
        expect(gateway).to have_received(:fetch_lookups_values).with(name: "built_form", schema_version: nil, lookup_key: "1")
      end
    end

    context "when searching for lookup values by name and lookup_key and schema" do
      it "extracts the data from the gateway" do
        use_case.execute(name: "built_form", lookup_key: "1", schema_version: "RdSAP-Schema-21.0.1")
        expect(gateway).to have_received(:fetch_lookups_values).with(name: "built_form", schema_version: "RdSAP-Schema-21.0.1", lookup_key: "1")
      end
    end

    context "when no data is found the inputs" do
      before do
        allow(gateway).to receive(:fetch_lookups_values).and_return []
      end

      it "raises a NoData error" do
        expect {
          use_case.execute(name: "nothing")
        }.to raise_error(Boundary::NoData, "There is no data return for 'lookup values'")
      end
    end
  end
end
