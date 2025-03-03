describe UseCase::FixAttributeDuplicates do
  subject(:use_case) do
    described_class.new(assessment_attribute_gateway:)
  end

  let(:assessment_attribute_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end

  describe "#execute" do
    context "when no duplicates are found" do
      before do
        allow(assessment_attribute_gateway).to receive_messages(fetch_duplicate_attributes: [], fix_duplicate_attributes: nil)
      end

      it "raises an no data error" do
        expect { use_case.execute }.to raise_error Boundary::NoData
      end
    end

    context "when duplicates are found" do
      let(:duplicates) do
        [{ "attribute_id" => 7, "attribute_name" => "dupe1", "row_number" => 2 },
         { "attribute_id" => 8, "attribute_name" => "dupe1", "row_number" => 3 },
         { "attribute_id" => 9, "attribute_name" => "dupe2", "row_number" => 2 },
         { "attribute_id" => 10, "attribute_name" => "dupe2", "row_number" => 3 }]
      end

      before do
        allow(assessment_attribute_gateway).to receive_messages(fetch_duplicate_attributes: duplicates, fix_duplicate_attributes: nil)
      end

      it "does not raise an nerror" do
        expect { use_case.execute }.not_to raise_error
      end

      it "returns the number of duplicateds to be fixed" do
        expect(use_case.execute).to eq 4
      end
    end
  end
end
