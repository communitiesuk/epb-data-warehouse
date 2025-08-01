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
        address: {
          type: "string",
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
    rescue StandardError => e
      report_to_sentry(e)
      json_api_response code: 500, data: { errors: [{ code: e.message }] }
    end

    get "/api/domestic/search", auth_token_has_all: %w[epb-data-front:read] do
      params_body SEARCH_SCHEMA
      execute_params = {
        date_start: params[:date_start],
        date_end: params[:date_end],
        council: params[:council],
        constituency: params[:constituency],
        postcode: params[:postcode],
        eff_rating: params[:eff_rating],
        assessment_type: %w[SAP RdSAP],
        address: params[:address],
      }
      use_case = Container.assessment_search_use_case
      result = use_case.execute(**execute_params)
      json_api_response code: 200, data: result
    rescue Boundary::Json::ValidationError, Boundary::InvalidDates
      dates_missing_error = "The search query was invalid - please provide a valid date range"
      json_api_response code: 400, data: { error: dates_missing_error }
    rescue Boundary::InvalidArgument
      includes_today_error = "The search query was invalid - the date cannot include today"
      json_api_response code: 400, data: { error: includes_today_error }
    rescue Errors::PostcodeNotValid
      postcode_invalid_error = "The search query was invalid - please prove a valid postcode"
      json_api_response code: 400, data: { error: postcode_invalid_error }
    rescue Errors::CouncilNotFound
      council_not_found_error = "The search query was invalid - provide valid council name(s)"
      json_api_response code: 400, data: { error: council_not_found_error }
    rescue Errors::ConstituencyNotFound
      constituency_not_found_error = "The search query was invalid - provide valid constituency name(s)"
      json_api_response code: 400, data: { error: constituency_not_found_error }
    rescue Boundary::NoData
      no_data_error = "No domestic assessments could be found for that query"
      json_api_response code: 404, data: { error: no_data_error }
    rescue StandardError => e
      report_to_sentry(e)
      json_api_response code: 500, data: { errors: [{ code: e.message }] }
    end
  end
end
