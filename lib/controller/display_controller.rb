module Controller
  class DisplayController < Controller::ApiBaseController
    get "/api/display/count", auth_token_has_all: %w[epb-data-front:read] do
      get_count(assessment_type: %w[DEC])
    end

    get "/api/display/search" do
      get_search_result(assessment_type: %w[DEC])
    end
  end
end
