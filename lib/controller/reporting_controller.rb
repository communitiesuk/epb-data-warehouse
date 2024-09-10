module Controller
  class ReportingController < Controller::BaseController
    get "/api/avg-co2-emissions", auth_token_has_all: %w[warehouse:read] do
      use_case = Container.fetch_average_co2_emissions_use_case
      json_api_response code: 200, data: use_case.execute
    end
  end
end
