describe UseCase::AddAssessment do
  context "when calling object in the class library" do
    subject { described_class.new }

    it "can execute the method" do
      expect(subject.execute).to eq(true)
    end
  end
end
