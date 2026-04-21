require "notifications/client"

describe "Sending emails to users" do
  context "when calling the rake task" do
    subject(:task) { get_task("send_email_to_users") }

    let(:test_user_emails) do
      "dave@test.com, jo@test.com"
    end

    let(:unsubscribe_link) do
      "https://#{ENV['DATA_SERVICE_URL']}/api/my-account"
    end

    let(:test_user_emails_arr) do
      test_user_emails.split(",").map(&:strip)
    end

    let(:encrypted_emails) do
      %w[encrypted_email_1 encrypted_email_2]
    end

    let(:notify_client) do
      instance_double(Notifications::Client)
    end

    let(:kms_gateway) do
      instance_double(Gateway::KmsGateway)
    end

    let(:user_credentials_gateway) do
      instance_double(Gateway::UserCredentialsGateway)
    end

    let(:notify_gateway) do
      instance_double(Gateway::NotifyGateway)
    end

    let(:stub_user_credentials_gateway) do
      instance_double(Helper::TaskGatewayStubs::UserCredentialsGateway)
    end

    let(:stub_kms_gateway) do
      instance_double(Helper::TaskGatewayStubs::KmsGateway)
    end

    before do
      allow(Notifications::Client).to receive(:new).and_return(notify_client)
      allow(Gateway::KmsGateway).to receive(:new).and_return(kms_gateway)
      allow(Gateway::UserCredentialsGateway).to receive(:new).and_return(user_credentials_gateway)
      allow(Gateway::NotifyGateway).to receive(:new).with(notify_client).and_return(notify_gateway)
      allow(Helper::TaskGatewayStubs::KmsGateway).to receive(:new).and_return(stub_kms_gateway)
      allow(Helper::TaskGatewayStubs::UserCredentialsGateway).to receive(:new).and_return(stub_user_credentials_gateway)
      allow(stub_user_credentials_gateway).to receive(:get_opt_in_users).and_return(test_user_emails_arr)
      allow(user_credentials_gateway).to receive(:get_opt_in_users).and_return(encrypted_emails)
      allow(stub_kms_gateway).to receive(:decrypt)

      test_user_emails_arr.each.with_index do |email, i|
        allow(stub_kms_gateway).to receive(:decrypt).with(email).and_return(email)
        allow(kms_gateway).to receive(:decrypt).with(encrypted_emails[i]).and_return(email)
      end

      allow(notify_gateway).to receive(:send_data_users_email)

      ENV["NOTIFY_DATA_EMAIL_USERS_TEMPLATE_ID"] = "some_template_id"
      ENV["DATA_SERVICE_URL"] = "get-energy-performance-data"
    end

    after do
      ENV.delete("NOTIFY_EMAIL_USERS_TEMPLATE_ID")
      ENV.delete("DATA_SERVICE_URL")
    end

    context "when sending messages to emails passed as an ENV variable" do
      before do
        ENV["TEST_USERS"] = test_user_emails
        task.invoke
      end

      after do
        ENV.delete("TEST_USERS")
      end

      it "calls the stubbed users credentials gateway class to inject users into the use case" do
        expect(stub_user_credentials_gateway).to have_received(:get_opt_in_users)
      end

      it "calls the stubbed KMS gateway class to inject users into the use case" do
        expect(stub_kms_gateway).to have_received(:decrypt).exactly(2).times
      end

      it "does not get data from DynamoDB" do
        expect(user_credentials_gateway).not_to have_received(:get_opt_in_users)
      end

      it "sends emails to stubbed users" do
        test_user_emails_arr.each do |email|
          expect(notify_gateway).to have_received(:send_data_users_email).with({ email_address: email, template_id: "some_template_id", unsubscribe_link: }).exactly(1).times
        end
      end
    end

    context "when sending production emails extracted from AWS" do
      before do
        ENV["PRODUCTION_SEND"] = "true"
        task.invoke
      end

      after do
        ENV.delete("PRODUCTION_SEND")
      end

      it "extracts users from DynamoDB" do
        expect(user_credentials_gateway).to have_received(:get_opt_in_users)
      end

      it "sends emails users" do
        test_user_emails_arr.each do |email|
          expect(notify_gateway).to have_received(:send_data_users_email).with({ email_address: email, template_id: "some_template_id", unsubscribe_link: }).exactly(1).times
        end
      end
    end

    context "when attempting to send production emails without correct ENV vars" do
      it "raises an error" do
        expect { task.invoke }.to raise_error Errors::SendEmailToUsersError
      end

      it "does not send any emails" do
        expect(notify_gateway).not_to have_received(:send_data_users_email)
      end
    end
  end
end
