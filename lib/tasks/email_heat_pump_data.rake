desc "Email Heat pump counts data "
task :email_heat_pump_data do
  start_date = ENV["START_DATE"]
  end_date = ENV["END_DATE"]
  email_address = ENV["EMAIL_RECIPIENT"] || ENV["NOTIFY_EMAIL_RECIPIENT"]
  template_id = ENV["NOTIFY_TEMPLATE_ID"]
  type_of_export = ENV["TYPE_OF_EXPORT"]

  last_months_dates = Tasks::TaskHelpers.get_last_months_dates
  start_date ||= last_months_dates[:start_date]
  end_date ||= last_months_dates[:end_date]

  use_case = case type_of_export
             when "property_type"
               Container.export_heat_pump_by_property_type_use_case
             when "floor_area"
               Container.export_heat_pump_by_floor_area_use_case
             end

  raise Boundary::InvalidExportType if use_case.nil?

  notification = use_case.execute(start_date:, end_date:, template_id:, email_address:)
  puts notification.status
rescue Boundary::InvalidExportType => e
  report_to_sentry(e)
rescue Boundary::NoData => e
  report_to_sentry(e)
rescue Notifications::Client::RequestError => e
  report_to_sentry(e)
end
