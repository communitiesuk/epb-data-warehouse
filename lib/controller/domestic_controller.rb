module Controller
  class DomesticController < Controller::ApiBaseController
    get "/api/domestic/count", auth_token_has_all: %w[epb-data-front:read] do
      get_count(assessment_type: %w[SAP RdSAP])
    end

    get "/api/domestic/search", has_bearer_token: true do
      get_search_result(assessment_type: %w[SAP RdSAP])
    end
  end
end
