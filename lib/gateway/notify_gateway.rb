require "notifications/client"

module Gateway
  class NotifyGateway
    def initialize(notify_api_key)
      @client = Notifications::Client.new(notify_api_key)
      @response = nil
    end

    def send_email(template_id:, file_name:, email_address:)
      file = File.open(file_name, "rb") do |f|
        Notifications.prepare_upload(f, filename: file_name, confirm_email_before_download: false)
      end
      @response = @client.send_email(
        email_address:,
        template_id:,
        personalisation: {
          link_to_file: file,
        },
      )
    end

    def check_email_status
      @client.get_notification(@response.id)
    end
  end
end
