describe Gateway::NotifyGateway do
  require_relative "../../shared_context/shared_send_heat_pump"
  subject(:gateway) { described_class.new(notify_client) }

  include_context "when sending heat pump data"

  context "when sending an email and file" do
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

  context "when sending email to data users" do
    let(:unsubscribe_link) do
      "https://get-energy-performance-data/api/my-account"
    end

    describe "#send_data_users_email" do
      let(:email_address) { "sender@something.com" }
      let(:mocked_response) do
        {
          "id": "201b576e-c09b-467b-9dfa-9c3b689ee730",

          "template": {
            "id": template_id,
            "version": 2,
            "uri": "https://api.notifications.service.gov.uk/v2/template/#{template_id}",
          },
        }
      end

      context "when Notification service responds successfully with 200" do
        before do
          WebMock.enable!
          WebMock.stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email").to_return(status: 200, body: mocked_response.to_json, headers: {})
        end

        it "returns the response id" do
          expect(gateway.send_data_users_email(template_id:, email_address:, unsubscribe_link:)).to eq("201b576e-c09b-467b-9dfa-9c3b689ee730")
        end

        it "a message is sent to the notify api" do
          gateway.send_data_users_email(template_id:, email_address:, unsubscribe_link:)
          expect(WebMock).to have_requested(:post, "https://api.notifications.service.gov.uk/v2/notifications/email").with(
            body: '{"email_address":"sender@something.com","template_id":"b46eb2e7-f7d3-4092-9865-76b57cc24922","personalisation":{"unsubscribe_link":"https://get-energy-performance-data/api/my-account"}}',
          )
        end
      end

      context "when the rate limit is reached" do
        before do
          WebMock.stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
                 .to_return(status: 429, body: "exceeded rate limit for key type TEAM of 10 requests per 10 seconds", headers: {})
        end

        it "re-raises the rate limit error" do
          expect { gateway.send_data_users_email(template_id:, email_address:, unsubscribe_link:) }.to raise_error Errors::NotifyRateLimit
        end
      end
    end
  end
end
