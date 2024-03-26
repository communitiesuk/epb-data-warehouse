require "csv"

module UseCase
  class ExportHeatPumpByPropertyType
    def initialize(export_gateway:, file_gateway:, notify_gateway:)
      @export_gateway = export_gateway
      @file_gateway = file_gateway
      @notify_gateway = notify_gateway
    end

    def execute(start_date:, end_date:, template_id:, file_name:, email_address:)
      @raw_data = @export_gateway.fetch_by_property_type(start_date:, end_date:)
      @file_gateway.save_csv(@raw_data)
      @notify_gateway.send_email(template_id:, file_name:, email_address:)
      File.delete(file_name)
    end
  end
end
