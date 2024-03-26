describe Gateway::FileGateway do
  subject(:gateway) { described_class.new(file_name) }

  let(:file_name) { "heat_pump_by_property_type.csv" }

  describe "#save_file" do
    let(:data) { [{ "property_type" => "House", "count" => 2 }, { "property_type" => "Bungalow", "count" => 1 }] }

    before do
      gateway.save_csv(data)
    end

    after do
      File.delete(file_name)
    end

    it "writes the file to the disk" do
      expect(File.exist?(file_name)).to be true
    end

    it "converts data into a csv" do
      table = CSV.parse(File.read(file_name), headers: true)
      expect(table.length).to eq 2
      expect(table.by_col[0]).to eq %w[House Bungalow]
      expect(table.by_col[1]).to eq %w[2 1]
    end

    it "exposed the file name" do
      expect(gateway.file_name).to eq(file_name)
    end
  end
end
