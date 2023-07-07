describe Helper::HashedAssessmentId do
  context "when an RRN is hashed" do
    # let(:atom) { "2021-07-21T11:26:28.045Z" }

    it "converts to the expected hashed assessment id" do
      expect(described_class.hash_rrn('1234-5678-1234-2278-1234')).to eq "3219a657a59c669870b97a97a00fd722b81dbb02ffed384e794782f4991a5687"
    end
  end
end