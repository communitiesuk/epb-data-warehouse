describe UseCase::WriteLookUpCodesS3 do
  subject(:use_case) do
    described_class.new s3_gateway:,
                        look_up_gateway:
  end

  let(:data) { [{ built_form: 1, construction_age_band: "2" }, { built_form: 5, construction_age_band: "NR" }] }

  let(:s3_gateway) do
    gateway = instance_double(Gateway::S3Gateway)
    allow(gateway).to receive(:write_csv_file)
    gateway
  end

  let(:look_up_gateway) do
    gateway = instance_double(Gateway::AssessmentLookupsGateway)
    allow(gateway).to receive(:fetch_look_up_csv_data).and_return(data)
    gateway
  end

  describe "#execute" do
    let(:bucket) { "bucket-name" }
    let(:file_name) { "data.csv" }

    before do
      use_case.execute(bucket:, file_name:)
    end

    it "extracts the look up data from the db" do
      expect(look_up_gateway).to have_received(:fetch_look_up_csv_data).exactly(1).times
    end

    it "sends the data to S3" do
      expect(s3_gateway).to have_received(:write_csv_file).with(bucket:, file_name:, data:).exactly(1).times
    end
  end
end
