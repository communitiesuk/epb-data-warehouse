desc "Email Heat pump counts data "
task :email_heat_pump_data do
  start_date = ENV["START_DATE"]
  end_date = ENV["END_DATE"]
  email_address = ENV["EMAIL_RECIPIENT"] || ENV["NOTIFY_EMAIL_RECIPIENT"]
  template_id = ENV["NOTIFY_TEMPLATE_ID"]
  type_of_export = ENV["TYPE_OF_EXPORT"]

  raise Boundary::InvalidExportType if type_of_export.nil?

  last_months_dates = Tasks::TaskHelpers.get_last_months_dates
  start_date ||= last_months_dates[:start_date]
  end_date ||= last_months_dates[:end_date]

  case type_of_export
  when "property_type"
    file_prefix = "heat_pump_count_by_property_type"
    gateway_method = :fetch_by_property_type
  when "floor_area"
    file_prefix = "heat_pump_count_by_floor_area"
    gateway_method = :fetch_by_floor_area
  when "local_authority"
    file_prefix = "heat_pump_count_by_local_authority"
    gateway_method = :fetch_by_local_authority
  else
    raise Boundary::InvalidExportType
  end

  notification = Container.send_heat_pump_counts_use_case.execute(start_date:, end_date:, template_id:, email_address:, file_prefix:, gateway_method:)
  puts notification.status
rescue Boundary::InvalidExportType => e
  report_to_sentry(e)
rescue Boundary::NoData => e
  report_to_sentry(e)
rescue Notifications::Client::RequestError => e
  report_to_sentry(e)
end
