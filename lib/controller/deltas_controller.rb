module Controller
  class DeltasController < Controller::BaseController
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
      },
    }.freeze

    get "/api/deltas" do
      params_body SEARCH_SCHEMA

      use_case = Container.fetch_audit_logs_use_case
      result = use_case.execute(date_start: params[:date_start], date_end: params[:date_end])
      json_api_response code: 200, data: result
    rescue Boundary::Json::ValidationError, Boundary::InvalidDates
      dates_missing_error = "The search query was invalid - please provide a valid date range"
      json_api_response code: 400, data: { error: dates_missing_error }
    rescue Boundary::InvalidArgument
      includes_today_error = "The search query was invalid - the date cannot include today"
      json_api_response code: 400, data: { error: includes_today_error }
    rescue Boundary::NoData
      no_data_error = "No audit logs could be found for that query"
      json_api_response code: 404, data: { error: no_data_error }
    rescue StandardError => e
      report_to_sentry(e)
      json_api_response code: 500, data: { errors: [{ code: e.message }] }
    end
  end
end
