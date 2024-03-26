describe UseCase::ExportHeatPumpByPropertyType do
  let(:export_gateway) do
    instance_double(Gateway::ExportHeatPumpsGateway)
  end

  let(:file_gateway) do
    instance_double(Gateway::FileGateway)
  end

  let(:use_case) do
    described_class.new(export_gateway:, file_gateway:, notify_gateway:)
  end

  let(:notify_gateway) do
    instance_double(Gateway::NotifyGateway)
  end

  let(:file_name) { "heat_pump_by_property_type.csv" }
  let(:template_id) { "b46eb2e7-f7d3-4092-9865-76b57cc24922" }
  let(:email_address) { "sender@something.com" }
  let(:test_notify_api_key) { "epcheatpumptest-c58430da-e28f-492a-869a-9db3a17d8193-3ba4f26b-8fa7-4d73-bf04-49e94c3e2438" }

  describe "#execute" do
    let(:data) do
      [{ "property_type" => "House", "count" => 2 }, { "property_type" => "Bungalow", "count" => 1 }]
    end

    before do
      allow(export_gateway).to receive(:fetch_by_property_type).and_return data
      allow(Gateway::FileGateway).to receive(:new).with(file_name).and_return(file_gateway)
      allow(file_gateway).to receive(:save_csv).with(data).and_return File
      allow(Gateway::NotifyGateway).to receive(:new).with(test_notify_api_key).and_return(notify_gateway)
      allow(notify_gateway).to receive(:send_email).and_return Notifications::Client::ResponseNotification
      File.new(file_name, "w")
      use_case.execute(start_date: "2023-01-01", end_date: "2023-01-31", template_id:, file_name:, email_address:)
    end

    it "calls the fetch_by_property_type method" do
      expect(export_gateway).to have_received(:fetch_by_property_type).with(start_date: "2023-01-01", end_date: "2023-01-31").exactly(1).times
    end

    it "calls the save_csv method" do
      expect(file_gateway).to have_received(:save_csv).with(data).exactly(1).times
    end

    it "calls the sends_email method" do
      expect(notify_gateway).to have_received(:send_email).with(template_id:, file_name:, email_address:).exactly(1).times
    end

    it "check the file has been deleted" do
      expect(File.exist?(file_name)).to be false
    end
  end
end
