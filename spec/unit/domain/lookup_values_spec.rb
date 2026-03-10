describe Domain::LookupValues do
  let(:domain) { described_class.new(data:) }

  let(:data) do
    [{ "key" => "1", "value" => "Detached", "schema_version" => "RdSAP-Schema-21.0.1", "assessment_type" => "RdSAP" },
     { "key" => "2", "value" => "Semi-Detached", "schema_version" => "RdSAP-Schema-21.0.1", "assessment_type" => "RdSAP" },
     { "key" => "3", "value" => "End-Terrace", "schema_version" => "RdSAP-Schema-21.0.1", "assessment_type" => "RdSAP" },
     { "key" => "4", "value" => "Mid-Terrace", "schema_version" => "RdSAP-Schema-21.0.1", "assessment_type" => "RdSAP" },
     { "key" => "5", "value" => "Enclosed End-Terrace", "schema_version" => "RdSAP-Schema-21.0.1", "assessment_type" => "RdSAP" },
     { "key" => "6", "value" => "Enclosed Mid-Terrace", "schema_version" => "RdSAP-Schema-21.0.1", "assessment_type" => "RdSAP" },
     { "key" => "NR", "value" => "Not Recorded", "schema_version" => "RdSAP-Schema-21.0.1", "assessment_type" => "RdSAP" },
     { "key" => "1", "value" => "Detached", "schema_version" => "SAP-Schema-19.0.0", "assessment_type" => "SAP" },
     { "key" => "2", "value" => "Semi-Detached", "schema_version" => "SAP-Schema-19.0.0", "assessment_type" => "SAP" },
     { "key" => "3", "value" => "End-Terrace", "schema_version" => "SAP-Schema-19.0.0", "assessment_type" => "SAP" },
     { "key" => "4", "value" => "Mid-Terrace", "schema_version" => "SAP-Schema-19.0.0", "assessment_type" => "SAP" },
     { "key" => "5", "value" => "Enclosed End-Terrace", "schema_version" => "SAP-Schema-19.0.0", "assessment_type" => "SAP" },
     { "key" => "6", "value" => "Enclosed Mid-Terrace", "schema_version" => "SAP-Schema-19.0.0", "assessment_type" => "SAP" }]
  end

  describe "#get_results" do
    it "converts the data into an array" do
      expect(domain.get_results).to be_an(Array)
    end

    it "groups the data into unique key" do
      expect(domain.get_results.length).to eq 7
    end

    it "the key has value of the number of items for that value by schema" do
      values = [
        { schema_version: "RdSAP-Schema-21.0.1", value: "Detached", assessment_type: "RdSAP" },
        { schema_version: "SAP-Schema-19.0.0", value: "Detached", assessment_type: "SAP" },
      ]
      expect(domain.get_results.first[:key]).to eq "1"
      expect(domain.get_results.first[:values]).to eq values
    end

    context "when there is only one row of data" do
      let(:domain) { described_class.new(data: row) }

      let(:row) do
        [{ "key" => "NR", "value" => "Not Recorded", "schema_version" => "RdSAP-Schema-21.0.1" }]
      end

      it "groups the data a single array" do
        expect(domain.get_results.length).to eq 1
        expect(domain.get_results.first[:key]).to eq "NR"
        expect(domain.get_results.first[:values].first[:value]).to eq "Not Recorded"
      end
    end
  end
end
