require "csv"

module UseCase
  class ExportHeatPumpByFloorArea
    def initialize(export_gateway:, file_gateway:, notify_gateway:)
      @export_gateway = export_gateway
      @file_gateway = file_gateway
      @notify_gateway = notify_gateway
    end

    def execute(start_date:, end_date:, template_id:, email_address:)
      file_name = "heat_pump_count_by_floor_area_#{Date.parse(start_date).strftime('%b_%Y')}.csv"
      raw_data = @export_gateway.fetch_by_floor_area(start_date:, end_date:)

      raise Boundary::NoData, "heat pump data by floor area" unless raw_data.any?

      @file_gateway.save_csv(raw_data, file_name)
      email_status = @notify_gateway.check_email_status

      @notify_gateway.send_email(template_id:, file_name:, email_address:)
      File.delete(file_name) if File.exist?(file_name)
      email_status
    end
  end
end
