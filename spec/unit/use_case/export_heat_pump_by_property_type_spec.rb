require_relative "../../shared_context/shared_send_heat_pump"

describe UseCase::ExportHeatPumpByPropertyType do
  include_context "when sending heat pump data"

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
  let(:email_address) { "sender@something.com" }

  describe "#execute" do
    let(:data) do
      [{ "property_type" => "House", "count" => 2 }, { "property_type" => "Bungalow", "count" => 1 }]
    end

    before do
      allow(export_gateway).to receive(:fetch_by_property_type).and_return data
      allow(Gateway::FileGateway).to receive(:new).with(file_name).and_return(file_gateway)
      allow(file_gateway).to receive(:save_csv).with(data).and_return File
      allow(file_gateway).to receive(:file_name).and_return file_name
      allow(Gateway::NotifyGateway).to receive(:new).with(notify_client).and_return(notify_gateway)
      allow(notify_gateway).to receive(:send_email).and_return Notifications::Client::ResponseNotification
      allow(notify_gateway).to receive(:check_email_status).and_return Notifications::Client::Notification
    end

    it "calls the fetch_by_property_type method" do
      use_case.execute(start_date: "2023-01-01", end_date: "2023-01-31", template_id:, email_address:)
      expect(export_gateway).to have_received(:fetch_by_property_type).with(start_date: "2023-01-01", end_date: "2023-01-31").exactly(1).times
    end

    it "calls the save_csv method" do
      use_case.execute(start_date: "2023-01-01", end_date: "2023-01-31", template_id:, email_address:)
      expect(file_gateway).to have_received(:save_csv).with(data).exactly(1).times
    end

    it "calls the sends_email method" do
      use_case.execute(start_date: "2023-01-01", end_date: "2023-01-31", template_id:, email_address:)
      expect(notify_gateway).to have_received(:send_email).with(template_id:, file_name:, email_address:).exactly(1).times
    end

    it "check the file has been deleted" do
      File.new(file_name, "w")
      use_case.execute(start_date: "2023-01-01", end_date: "2023-01-31", template_id:, email_address:)
      expect(File.exist?(file_name)).to be false
    end

    it "returns the status of the email" do
      status = use_case.execute(start_date: "2023-01-01", end_date: "2023-01-31", template_id:, email_address:)
      expect(status).to eq Notifications::Client::Notification
    end

    context "when there is no data" do
      before do
        allow(export_gateway).to receive(:fetch_by_property_type).and_return []
      end

      it "raises a no data error" do
        expect { use_case.execute(start_date: "2023-01-01", end_date: "2023-01-31", template_id:, email_address:) }.to raise_error Boundary::NoData
      end
    end

    context "when a Notifications error is raised" do
      before do
        allow(notify_gateway).to receive(:send_email).and_raise Notifications::Client::RequestError.new(stub_notify_response)
      end

      it "raises a Notifications request error" do
        expect { use_case.execute(start_date: "2023-01-01", end_date: "2023-01-31", template_id:, email_address:) }.to raise_error(Notifications::Client::RequestError)
      end
    end
  end
end
