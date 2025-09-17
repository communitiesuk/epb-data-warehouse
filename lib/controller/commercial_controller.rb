module Controller
  class CommercialController < Controller::ApiBaseController
    get "/api/commercial/count", auth_token_has_all: %w[epb-data-front:read] do
      get_count(assessment_type: %w[CEPC])
    end
  end
end
