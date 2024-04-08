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

      raise Boundary::NoData, "heat pump data" unless raw_data.any?

      email_status = nil
      @file_gateway.save_csv(raw_data, file_name)
      begin
        @notify_gateway.send_email(template_id:, file_name:, email_address:)
        email_status = @notify_gateway.check_email_status
      rescue Notifications::Client::RequestError
        raise
      end
      File.delete(file_name) if File.exist?(file_name)
      email_status
    end
  end
end
