require_relative "../shared_context/shared_send_heat_pump"

context "when calling the email heat pump rake task" do
  subject(:task) { get_task("email_heat_pump_data") }

  include_context "when sending heat pump data"

  let(:export_gateway) do
    instance_double(Gateway::ExportHeatPumpsGateway)
  end

  let(:file_gateway) do
    instance_double(Gateway::FileGateway)
  end

  let(:use_case) do
    instance_double(UseCase::ExportHeatPumpByPropertyType)
  end

  let(:notify_gateway) do
    instance_double(Gateway::NotifyGateway)
  end

  let(:file_name) { "heat_pump_count_by_property_type.csv" }
  let(:email_address) { "sender@something.com" }
  let(:start_date) { "2024-02-01" }
  let(:end_date) { "2024-02-29" }
  let(:notification) do
    instance_double(Notifications::Client::Notification)
  end

  before do
    Timecop.freeze(2024, 3, 1, 7, 0, 0)
    allow(Container).to receive(:export_heat_pumps_gateway).and_return export_gateway
    allow(Container).to receive(:file_gateway).with(file_name).and_return file_gateway
    allow(Container).to receive(:notify_gateway).and_return notify_gateway
    allow(Container).to receive(:export_heat_pump_by_property_type_use_case).and_return use_case
    allow(UseCase::ExportHeatPumpByPropertyType).to receive(:new).with(export_gateway:, file_gateway:, notify_gateway:).and_return use_case
    allow(notification).to receive(:status).and_return "sending"
    allow(use_case).to receive(:execute).and_return notification
    allow($stdout).to receive(:puts)
    ENV["NOTIFY_TEMPLATE_ID"] = template_id
    ENV["EMAIL_ADDRESS"] = email_address
  end

  after do
    ENV["NOTIFY_TEMPLATE_ID"] = nil
    ENV["EMAIL_ADDRESS"] = nil
  end

  it "doesn't error" do
    expect { task.invoke }.not_to raise_error
  end

  it "passed the correct arguments to the use case" do
    task.invoke
    expect(use_case).to have_received(:execute).with(template_id:, email_address:, start_date:, end_date:)
  end

  it "prints the Notification class to the console" do
    expect { task.invoke }.to output(/sending/).to_stdout
  end
end
