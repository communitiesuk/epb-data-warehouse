describe Helper::MetaDataRule do
  describe "#should_exclude?" do
    context "when metadata type of assessment is not AC-REPORT" do
      it "responds that the assessment should not be excluded" do
        expect(IncludedRule.new.should_exclude?(meta_data: { typeOfAssessment: "DEC" })).to be false
      end
    end

    context "when metadata type of assessment is AC-REPORT" do
      it "responses that the assessment should be excluded" do
        expect(IncludedRule.new.should_exclude?(meta_data: { typeOfAssessment: "AC-REPORT" })).to be true
      end
    end

    context "when metadata does not have typeOfAssessment (for example, test cases)" do
      it "responds that the assessment should not be excluded" do
        expect(IncludedRule.new.should_exclude?(meta_data: {})).to be false
      end
    end
  end

  describe "#is_cancelled?" do
    context "when the metadata has cancelledAt" do
      it "returns true" do
        expect(IncludedRule.new.is_cancelled?(meta_data: { cancelledAt: "2023-08-29T14:54:15.012Z", notForIssueAt: nil })).to be true
      end
    end

    context "when the metadata has notForIssueAt" do
      it "returns true" do
        expect(IncludedRule.new.is_cancelled?(meta_data: { cancelledAt: nil, notForIssueAt: "2023-08-29T14:54:15.012Z" })).to be true
      end
    end

    context "when the metadata has notForIssueAt and cancelledAt as nil" do
      it "returns false" do
        expect(IncludedRule.new.is_cancelled?(meta_data: { cancelledAt: nil, notForIssueAt: nil })).to be false
      end
    end
  end

  describe "#is_green_deal?" do
    context "when the metadata has greenDeal" do
      it "returns true" do
        expect(IncludedRule.new.is_green_deal?(meta_data: { greenDeal: true })).to be true
      end
    end

    context "when the metadata does not have a greenDeal" do
      it "returns false" do
        expect(IncludedRule.new.is_green_deal?(meta_data: {})).to be false
      end
    end
  end
end

class IncludedRule
  include Helper::MetaDataRule
end
