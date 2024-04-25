class DataWarehouseApiService < Controller::BaseController
  if ENV["DATABASE_URL"].nil?
    raise ArgumentError, "Please set DATABASE_URL"
  end

  ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

  use Controller::HomeController
  use Controller::HeatPumpController
end
