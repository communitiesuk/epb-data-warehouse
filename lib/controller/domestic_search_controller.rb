module Controller
  class DomesticSearchController < Controller::BaseController
    SEARCH_SCHEMA = {
      type: "object",
      required: %w[date_start date_end],
      properties: {
        date_start: {
          type: "string",
        },
        date_end: {
          type: "string",
        },
        council: {
          type: "array",
          items: { type: "string" },
        },
        constituency: {
          type: "array",
          items: { type: "string" },
        },
        postcode: {
          type: "string",
        },
        eff_rating: {
          type: "array",
          items: { type: "string" },
        },
      },
    }.freeze

    get "/api/domestic/count", auth_token_has_all: %w[epb-data-front:read] do
      params_body SEARCH_SCHEMA
      execute_params = {
        date_start: params[:date_start],
        date_end: params[:date_end],
        council: params[:council],
        constituency: params[:constituency],
        postcode: params[:postcode],
        eff_rating: params[:eff_rating],
      }
      use_case = Container.count_domestic_certificates_use_case
      result = use_case.execute(**execute_params)
      json_api_response code: 200, data: { count: result }
    end
  end
end
