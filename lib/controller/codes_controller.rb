module Controller
  class CodesController < Controller::BaseController
    get "/api/codes", auth_token_has_all: %w[warehouse:read] do
      use_case = Container.fetch_look_ups_use_case
      result = use_case.execute
      json_api_response code: 200, data: result
    end
  end
end
