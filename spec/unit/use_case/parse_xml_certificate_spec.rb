describe UseCase::ParseXmlCertificate do
  subject(:use_case) { described_class.new }

  let(:assessment_id) do
    "0000-0000-0000-0000-0000"
  end

  let(:schema_type) { "RdSAP-Schema-20.0.0" }

  let(:sample) do
    Samples.xml(schema_type)
  end

  shared_examples "test parse" do |use_subprocess:|
    it "parses out XML into a hash" do
      expect(use_case.execute(xml: sample, schema_type:, assessment_id:, use_subprocess:)).to include(
        "country_code" => "EAW",
        "region_code" => 1,
      )
    end
  end

  context "when using subprocess" do
    include_examples "test parse", use_subprocess: true
  end

  context "when not using subprocess" do
    include_examples "test parse", use_subprocess: false
  end

  context "when using a schema type that is not parsed" do
    it "returns nil" do
      expect(use_case.execute(xml: sample, schema_type: "SAP-Schema-NI-17.0", assessment_id:)).to be nil
    end
  end
end
