describe Helper::DateTime do
  context "when valid date time in ATOM (ISO-8601) format is given" do
    let(:atom) { "2021-07-21T11:26:28.045Z" }

    it "converts to the expected XXXX-XX-XX XX:XX:XX format" do
      expect(described_class.convert_atom_to_db_datetime(atom)).to eq "2021-07-21 11:26:28"
    end
  end

  context "when nil is given as the date" do
    it "returns nil" do
      expect(described_class.convert_atom_to_db_datetime(nil)).to be nil
    end
  end
end
