describe Helper::MetaDataRule do
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

class IncludedRule
  include Helper::MetaDataRule
end
