require "notifications/client"

module Gateway
  class NotifyGateway
    def initialize(notify_client)
      @client = notify_client
      @response = nil
    end

    def send_email(template_id:, file_name:, email_address:, email_subject:)
      file = File.open(file_name, "rb") do |f|
        Notifications.prepare_upload(f, filename: file_name, confirm_email_before_download: false)
      end
      @response = @client.send_email(
        email_address:,
        template_id:,
        personalisation: {
          link_to_file: file,
          subject: email_subject,
        },
      )
    end

    def check_email_status
      @client.get_notification(@response.id)
    end
  end
end
