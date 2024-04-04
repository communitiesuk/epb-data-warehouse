require "csv"

module UseCase
  class ExportHeatPumpByPropertyType
    def initialize(export_gateway:, file_gateway:, notify_gateway:)
      @export_gateway = export_gateway
      @file_gateway = file_gateway
      @notify_gateway = notify_gateway
    end

    def execute(start_date:, end_date:, template_id:, email_address:)
      file_name = @file_gateway.file_name
      raw_data = @export_gateway.fetch_by_property_type(start_date:, end_date:)

      raise Boundary::NoData, "heat pump data" unless raw_data.any?

      email_status = nil
      @file_gateway.save_csv(raw_data)
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
