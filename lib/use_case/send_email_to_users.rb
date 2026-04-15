module UseCase
  class SendEmailToUsers
    def initialize(user_credentials_gateway:, notify_gateway:, kms_gateway:)
      @user_credentials_gateway = user_credentials_gateway
      @notify_gateway = notify_gateway
      @kms_gateway = kms_gateway
    end

    def execute(notify_template_id)
      emails = @user_credentials_gateway.get_opt_in_users
      emails.each do |encrypted_email|
        begin
          email = @kms_gateway.decrypt(encrypted_email)
        rescue Errors::KmsDecryptionError
          next
        end
        @notify_gateway.send_data_users_email(template_id: notify_template_id, email_address: email)
      end
    end
  end
end
