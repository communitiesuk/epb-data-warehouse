module Controller
  class CommercialController < Controller::ApiBaseController
    get "/api/non-domestic/count", auth_token_has_all: %w[epb-data-front:read] do
      get_count(assessment_type: %w[CEPC])
    end

    get "/api/non-domestic/search", has_bearer_token: true do
      get_search_result(assessment_type: %w[CEPC])
    end
  end
end
