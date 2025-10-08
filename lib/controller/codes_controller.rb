module Controller
  class CodesController < Controller::BaseController
    SEARCH_SCHEMA = {
      type: "object",
      required: %w[code],
      properties: {
        code: {
          type: "string",
        },
        schema_version: {
          type: "string",
        },
        key: {
          type: "string",
        },
      },
    }.freeze

    get "/api/codes" do
      use_case = Container.fetch_look_ups_use_case
      result = use_case.execute
      json_api_response code: 200, data: result
    end

    get "/api/codes/info" do
      execute_params = {
        name: params[:code],
        schema_version: params[:schema_version],
        lookup_key: params[:key],
      }

      use_case = Container.fetch_look_up_values_use_case
      result = use_case.execute(**execute_params)
      json_api_response code: 200, data: result
    rescue Boundary::NoData
      no_data_error = "No codes could be found for that query"
      json_api_response code: 404, data: { error: no_data_error }
    rescue StandardError => e
      report_to_sentry(e)
      json_api_response code: 500, data: { errors: [{ code: e.message }] }
    end
  end
end
