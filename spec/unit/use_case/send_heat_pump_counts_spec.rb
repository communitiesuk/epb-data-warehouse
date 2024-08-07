require_relative "../../shared_context/shared_send_heat_pump"

describe UseCase::SendHeatPumpCounts do
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

  let(:gateway_method) do
    :fetch_by_floor_area
  end

  let(:file_prefix) { "heat_pump_count_by_floor_area" }
  let(:file_name) { "heat_pump_count_by_floor_area_Jan_2023.csv" }
  let(:email_address) { "sender@something.com" }
  let(:email_subject) { "Count of assessments with heat pumps by floor area Jan 2023" }

  describe "#execute" do
    let(:data) do
      [{ "total_floor_area" => "BETWEEN 0 AND 50", "count" => 1 },
       { "total_floor_area" => "BETWEEN 101 AND 150", "count" => 2 },
       { "total_floor_area" => "BETWEEN 151 AND 200", "count" => 1 },
       { "total_floor_area" => "BETWEEN 201 AND 250", "count" => 1 },
       { "total_floor_area" => "BETWEEN 51 AND 100", "count" => 1 },
       { "total_floor_area" => "GREATER THAN 251", "count" => 1 }]
    end

    let(:args) do
      {
        start_date: "2023-01-01",
        end_date: "2023-01-31",
        template_id:,
        email_address:,
        file_prefix:,
        gateway_method:,
      }
    end

    let(:client_response) do
      instance_double(Notifications::Client::Notification, status: "sending")
    end

    before do
      allow($stdout).to receive(:puts)
      allow(export_gateway).to receive(gateway_method).and_return data
      allow(Gateway::FileGateway).to receive(:new).and_return(file_gateway)
      allow(file_gateway).to receive(:save_csv).with(data, file_name).and_return File
      allow(Gateway::NotifyGateway).to receive(:new).with(notify_client).and_return(notify_gateway)
      allow(notify_gateway).to receive_messages(send_email: Notifications::Client::ResponseNotification, check_email_status: client_response)
    end

    it "calls the correct gateway method" do
      use_case.execute(**args)
      expect(export_gateway).to have_received(gateway_method).with(start_date: "2023-01-01", end_date: "2023-01-31").exactly(1).times
    end

    it "calls the save_csv method" do
      use_case.execute(**args)
      expect(file_gateway).to have_received(:save_csv).with(data, file_name).exactly(1).times
    end

    it "calls the sends_email method with the correct arguments" do
      use_case.execute(**args)
      expect(notify_gateway).to have_received(:send_email).with(template_id:, file_name:, email_address:, email_subject:).exactly(1).times
    end

    it "check the file has been deleted" do
      File.new(file_name, "w")
      use_case.execute(**args)
      expect(File.exist?(file_name)).to be false
    end

    it "outputs the status of the email" do
      expect { use_case.execute(**args) }.to output("sending\n").to_stdout
    end

    context "when there is no data" do
      before do
        allow(export_gateway).to receive(gateway_method).and_return []
      end

      it "raises a no data error" do
        expect { use_case.execute(**args) }.to raise_error Boundary::NoData
      end
    end

    context "when a Notifications error is raised" do
      before do
        allow(notify_gateway).to receive(:send_email).and_raise Notifications::Client::RequestError.new(stub_notify_response)
      end

      it "raises a Notifications request error" do
        expect { use_case.execute(**args) }.to raise_error(Notifications::Client::RequestError)
      end
    end

    context "when sending to more than 1 recipient" do
      let(:email_address) do
        "sender@something.com,another_person@something.com"
      end

      it "calls the send method for each recipient" do
        use_case.execute(**args)
        expect(notify_gateway).to have_received(:send_email).with(template_id:, file_name:, email_address: "sender@something.com", email_subject:).exactly(1).times
        expect(notify_gateway).to have_received(:send_email).with(template_id:, file_name:, email_address: "another_person@something.com", email_subject:).exactly(1).times
      end

      it "outputs the status of the each email" do
        expect { use_case.execute(**args) }.to output("sending\nsending\n").to_stdout
      end
    end
  end
end
