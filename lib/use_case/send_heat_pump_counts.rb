require "csv"

module UseCase
  class SendHeatPumpCounts
    def initialize(export_gateway:, file_gateway:, notify_gateway:)
      @export_gateway = export_gateway
      @file_gateway = file_gateway
      @notify_gateway = notify_gateway
    end

    def execute(start_date:, end_date:, template_id:, email_address:, file_prefix:, gateway_method:)
      file_name = "#{file_prefix}_#{Date.parse(start_date).strftime('%b_%Y')}.csv"
      raw_data = @export_gateway.method(gateway_method).call(start_date:, end_date:)
      subject_suffix = file_name.tr("_", " ").split("by")[1].split(".")[0]
      email_subject = "Count of assessments with heat pumps by#{subject_suffix}"

      raise Boundary::NoData, "heat pump data" unless raw_data.any?

      @file_gateway.save_csv(raw_data, file_name)
      email_address.split(",").each do |email|
        send_email(template_id:, file_name:, email_address: email, email_subject:)
      end

      File.delete(file_name) if File.exist?(file_name)
    end

  private

    def send_email(template_id:, file_name:, email_address:, email_subject:)
      @notify_gateway.send_email(template_id:, file_name:, email_address:, email_subject:)
      response = @notify_gateway.check_email_status
      puts response.status
    rescue Notifications::Client::RequestError
      raise
    end
  end
end
