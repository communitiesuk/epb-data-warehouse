module Controller
  class HeatPumpController < Controller::BaseController
    get "/api/heat-pump-counts/floor-area" do
      use_case = Container.get_heat_pump_counts_by_floor_area_use_case
      result = use_case.execute(start_date: "2023-05-01", end_date: "2023-05-31")
      json_api_response code: 200, data: result
    end
  end
end
