describe UseCase::SendEmailToUsers do
  let(:user_credentials_gateway) do
    instance_double(Gateway::UserCredentialsGateway)
  end

  let(:kms_gateway) do
    instance_double(Gateway::KmsGateway)
  end

  let(:notify_gateway) do
    instance_double(Gateway::NotifyGateway)
  end

  let(:template_id) { "template_id" }

  let(:use_case) do
    described_class.new(user_credentials_gateway:, notify_gateway:, kms_gateway:)
  end

  describe "#execute" do
    let(:emails) do
      %w[test@email.com name.test@email.com]
    end

    let(:encrypted_emails) do
      %w[encrypted_email_1 encrypted_email_2]
    end

    before do
      allow(user_credentials_gateway).to receive(:get_opt_in_users).and_return encrypted_emails
      allow(notify_gateway).to receive(:send_data_users_email)
      allow(kms_gateway).to receive(:decrypt).with(encrypted_emails[0]).and_return(emails[0])
      allow(kms_gateway).to receive(:decrypt).with(encrypted_emails[1]).and_return(emails[1])
      use_case.execute(template_id)
    end

    it "extracts the emails addresses" do
      expect(user_credentials_gateway).to have_received(:get_opt_in_users).exactly(1).times
    end

    it "decrypts the email addresses" do
      expect(kms_gateway).to have_received(:decrypt).exactly(2).times
    end

    it "sends message to notify for each user" do
      emails.each do |email|
        expect(notify_gateway).to have_received(:send_data_users_email).with(template_id:, email_address: email).exactly(1).times
      end
    end

    context "when sending one of the emails raises an decrypt error" do
      let(:bad_email) do
        "bad.email@test.com"
      end

      before do
        emails.insert(1, bad_email)
        allow(notify_gateway).to receive(:send_data_users_email).with(template_id: template_id, email_address: bad_email).and_raise(Errors::NotifySendEmailError)
      end

      it "skips over the error and sends emails to the rest" do
        expect(notify_gateway).to have_received(:send_data_users_email).exactly(2).times
      end

      it "does not raise that error" do
        expect { use_case.execute(template_id) }.not_to raise_error
      end
    end

    context "when the rate limit is reached" do
      before do
        allow(notify_gateway).to receive(:send_data_users_email).and_raise(Errors::NotifyRateLimit)
      end

      it "the error is bubbled up to the use case" do
        expect { use_case.execute(template_id) }.to raise_error(Errors::NotifyRateLimit)
      end
    end
  end
end
