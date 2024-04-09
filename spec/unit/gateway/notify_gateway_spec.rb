describe Gateway::NotifyGateway do
  require_relative "../../shared_context/shared_send_heat_pump"
  subject(:gateway) { described_class.new(notify_client) }

  include_context "when sending heat pump data"

  let(:file_name) { "heat_pump_by_property_type.csv" }

  let(:data) { [{ "property_type" => "House", "count" => 2 }, { "property_type" => "Bungalow", "count" => 1 }] }
  let(:email_address) { "sender@something.com" }
  let(:email_subject) { "EPC test subject" }
  let(:mocked_response) do
    {
      "email_address" => email_address,
      "template_id" => template_id,
      "personalisation" => {
        "link_to_file" => {
          "file" => "cHJvcGVydHlfdHlwZSxjb3VudApIb3VzZSwyCkJ1bmdhbG93LDEK",
          "filename" => file_name,
          "confirm_email_before_download" => false,
        },
      },
    }
  end

  before do
    Gateway::FileGateway.new.save_csv(data, file_name)
    WebMock.enable!
    WebMock.stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .to_return(status: 200, body: mocked_response.to_json, headers: {})
  end

  after do
    File.delete(file_name)
    WebMock.disable!
  end

  describe "#send_email" do
    it "sends an email" do
      expect(gateway.send_email(template_id:, file_name:, email_address:, email_subject:)).to be_a Notifications::Client::ResponseNotification
      expect(WebMock).to have_requested(
        :post,
        "https://api.notifications.service.gov.uk/v2/notifications/email",
      ).with(
        body: '{"email_address":"sender@something.com","template_id":"b46eb2e7-f7d3-4092-9865-76b57cc24922","personalisation":{"link_to_file":{"file":"cHJvcGVydHlfdHlwZSxjb3VudApIb3VzZSwyCkJ1bmdhbG93LDEK","filename":"heat_pump_by_property_type.csv","confirm_email_before_download":false,"retention_period":null},"subject":"EPC test subject"}}',
      )
    end
  end

  describe "#check_email_status" do
    before do
      WebMock.stub_request(:get, "https://api.notifications.service.gov.uk/v2/notifications")
        .to_return(status: 200, body: mocked_response.to_json, headers: {})
    end

    it "confirms delivery status of the email" do
      gateway.send_email(template_id:, file_name:, email_address:, email_subject:)
      expect(gateway.check_email_status).to be_a Notifications::Client::Notification
    end
  end
end
