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

    def get_search_result(assessment_type:)
      params[:current_page] = (params["current_page"] || 1).to_i
      params[:page_size] = (params["page_size"] || 5000).to_i

      params_body SEARCH_SCHEMA
      execute_params = {
        date_start: params[:date_start],
        date_end: params[:date_end],
        council: Helper::SearchParams.title_case(params[:council]),
        constituency: Helper::SearchParams.title_case(params[:constituency]),
        postcode: params[:postcode],
        uprn: params[:uprn],
        eff_rating: Helper::SearchParams.format_band(params[:eff_rating]),
        assessment_type:,
        address: params[:address],
        current_page: params[:current_page],
        row_limit: params[:page_size],
      }

      Helper::SearchParams.validate(**execute_params)
      pagination_use_case = Container.get_pagination_use_case
      pagination_use_case.row_limit = params[:page_size]
      pagination_hash = pagination_use_case.execute(**execute_params)

      assessment_search_use_case = Container.assessment_search_use_case
      result = assessment_search_use_case.execute(**execute_params)
      json_api_response code: 200, data: result, pagination: pagination_hash
    rescue Boundary::Json::ValidationError
      params_missing_error = "The search query was invalid - please provide a valid date range or search parameter"
      json_api_response code: 400, data: { error: params_missing_error }
    rescue Boundary::InvalidDates
      dates_missing_error = "The search query was invalid - please provide a valid date range"
      json_api_response code: 400, data: { error: dates_missing_error }
    rescue Boundary::InvalidArgument
      includes_today_error = "The search query was invalid - the date cannot include today"
      json_api_response code: 400, data: { error: includes_today_error }
    rescue Boundary::InvalidArgumentType
      uprn_invalid_type_error = "The search query was invalid - the uprn should be an integer greater than 0"
      json_api_response code: 400, data: { error: uprn_invalid_type_error }
    rescue Errors::PostcodeNotValid
      postcode_invalid_error = "The search query was invalid - please provide a valid postcode"
      json_api_response code: 400, data: { error: postcode_invalid_error }
    rescue Errors::CouncilNotFound
      council_not_found_error = "The search query was invalid - provide valid council name(s)"
      json_api_response code: 400, data: { error: council_not_found_error }
    rescue Errors::ConstituencyNotFound
      constituency_not_found_error = "The search query was invalid - provide valid constituency name(s)"
      json_api_response code: 400, data: { error: constituency_not_found_error }
    rescue Boundary::NoData
      no_data_error = "No assessments could be found for that query"
      json_api_response code: 404, data: { error: no_data_error }
    rescue Errors::OutOfPaginationRangeError => e
      out_of_pagination_range_error = "The requested page number #{params[:current_page]} is out of range. #{e.message}"
      json_api_response code: 400, data: { error: out_of_pagination_range_error }
    rescue Errors::OutOfPageSizeRangeError
      page_size_message = "The requested page size #{params[:page_size]} is out of range. Please provide a page size between 1 and 5000"
      json_api_response code: 400, data: { error: page_size_message }
    rescue StandardError => e
      report_to_sentry(e)
      json_api_response code: 500, data: { errors: [{ code: e.message }] }
    end

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
