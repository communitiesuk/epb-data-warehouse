describe UseCase::ImportJsonCertificates do
  subject do
    described_class.new(directory_gateway, assessment_attribute_gateway)
  end

  let(:directory_gateway) { instance_double(Gateway::JsonCertificates) }

  let(:assessment_attribute_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end

  let!(:files) do
    path = File.join Dir.pwd, "spec/fixtures/json_export/"
    Dir
      .glob(File.join(path, "**", "*"))
      .select { |file| File.file?(file) && File.extname(file) == ".json" }
  end

  before do
    allow(directory_gateway).to receive(:read).and_return(files)
    allow(assessment_attribute_gateway).to receive(:add_attribute_value)
                                             .and_return(1)
  end

  it "imports 3 files from the fixtures" do
    expect(files.count).to eq(3)
  end

  context "when use case uses the actual attribute gateway" do
    before do
      use_case =
        described_class.new(
          directory_gateway,
          Gateway::AssessmentAttributesGateway.new,
        )
      use_case.execute
    end

    let!(:imported_data) do
      use_case =
        described_class.new(
          directory_gateway,
          Gateway::AssessmentAttributesGateway.new,
        )
      use_case.execute

      ActiveRecord::Base.connection.exec_query(
        'SELECT aa.*, aav.attribute_value,  aav.attribute_value_int, aav.attribute_value_float, aav.assessment_id
            FROM assessment_attribute_values aav
            JOIN assessment_attributes aa ON aav.attribute_id = aa.attribute_id',
      )
    end

    it "the assessment_attribute_values table has data for each of the 3 test assessments" do
      expect(
        imported_data.group_by { |item| item["assessment_id"] }.count,
      ).to eq(3)
    end

    it "the assessment_attribute_values has one entry for each type of assessment" do
      select =
        imported_data.select do |item|
          item["attribute_name"] == "type_of_assessment"
        end
      expect(select.map { |item| item["attribute_value"] }).to eq(
        %w[RdSAP CEPC SAP],
      )
    end

    it "the assessment_attribute_values table has CEPC data for asset_rating" do
      arr =
        imported_data.select do |result|
          result["attribute_name"] == "asset_rating"
        end
      expect(arr[0]["attribute_value"]).to eq("80")
      expect(arr[0]["parent_name"]).to eq(nil)
      expect(arr[0]["attribute_value_int"]).to eq(80)
    end

    it "returns SAP data for current_carbon_emission" do
      arr =
        imported_data.select do |result|
          result["attribute_name"] == "current_carbon_emission"
        end
      expect(arr[0]["attribute_value"]).to eq("2.4")
      expect(arr[0]["parent_name"]).to eq(nil)
      expect(arr[0]["attribute_value_float"]).to eq(2.4)
    end

    it "the attribute table should contain one hash for the town with a parent of address" do
      arr =
        imported_data.select { |result| result["attribute_name"] == "town" }
      expect(arr[0]["attribute_value"]).to eq("Whitbury")
      expect(arr[0]["parent_name"]).to eq("address")
    end
  end
end