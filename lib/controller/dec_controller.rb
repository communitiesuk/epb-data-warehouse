module Controller
  class DecController < Controller::ApiBaseController
    get "/api/dec/count", auth_token_has_all: %w[epb-data-front:read] do
      get_count(assessment_type: %w[DEC])
    end

    get "/api/dec/search" do
      get_search_result(assessment_type: %w[DEC])
    end
  end
end
