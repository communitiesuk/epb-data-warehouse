module Controller
  class ApiBaseController < Controller::BaseController
    SEARCH_SCHEMA = {
      type: "object",
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
        uprn: {
          type: "string",
        },
        current_page: {
          type: "integer",
        },
        page_size: {
          type: "integer",
        },

      },
      anyOf: [
        { required: %w[date_start date_end] },
        {
          anyOf: [
            { required: %w[council] },
            { required: %w[constituency] },
            { required: %w[postcode] },
            { required: %w[eff_rating] },
            { required: %w[address] },
            { required: %w[uprn] },
          ],
        },
      ],
    }.freeze

    def get_count(assessment_type:)
      params_body SEARCH_SCHEMA
      execute_params = {
        date_start: params[:date_start],
        date_end: params[:date_end],
        council: params[:council],
        constituency: params[:constituency],
        postcode: params[:postcode],
        eff_rating: params[:eff_rating],
        assessment_type:,
      }
      use_case = Container.count_certificates_use_case
      result = use_case.execute(**execute_params)
      json_api_response code: 200, data: { count: result }
    rescue StandardError => e
      report_to_sentry(e)
      json_api_response code: 500, data: { errors: [{ code: e.message }] }
    end
  end
end
