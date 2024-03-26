desc "Email Heat pump counts data "
task :email_heat_pump_data do |_, args|
  start_date = args[:start_date] || ENV["START_DATE"]
  end_date = args[:end_date] || ENV["END_DATE"]
  email_address = args[:email_address] || ENV["EMAIL_ADDRESS"]
  template_id = ENV["NOTIFY_TEMPLATE_ID"]

  last_months_dates = Tasks::TaskHelpers.get_last_months_dates
  start_date ||= last_months_dates[:start_date]
  end_date ||= last_months_dates[:end_date]

  use_case = Container.export_heat_pump_by_property_type_use_case
  status = use_case.execute(start_date:, end_date:, template_id:, email_address:)
  puts status
end
