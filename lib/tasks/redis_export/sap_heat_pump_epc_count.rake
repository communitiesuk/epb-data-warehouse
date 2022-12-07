namespace :redis_export do
  desc "Export counts of SAP EPCs with a heat pump as the main heating description by month-year"
  task :save_heat_pump_sap_count do
    Tasks::TaskHelpers.quit_if_production
    use_case(:save_heat_pump_sap_count).execute
  end
end
