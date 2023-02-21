# frozen_string_literal: true

module Gateway
  class RegisterApiGateway
    def initialize(api_client:)
      @internal_api_client = api_client
    end

    def fetch(assessment_id)
      route = "/api/assessments/#{CGI.escape(assessment_id)}"

      response =
        Helper::Response.ensure_good { @internal_api_client.get(route) }

      check_errors_on(response, assessment_id:)

      response.body
    end

    def fetch_meta_data(assessment_id)
      route = "/api/assessments/#{CGI.escape(assessment_id)}/meta-data"

      response =
        Helper::Response.ensure_good { @internal_api_client.get(route) }

      check_errors_on(response, assessment_id:)

      JSON.parse(response.body, symbolize_names: true)[:data]
    end

  private

    def check_errors_on(response, assessment_id:)
      case response.status
      when 400
        raise Errors::AssessmentNotFound, assessment_id
      when 404
        raise Errors::AssessmentNotFound, assessment_id
      when 410
        raise Errors::AssessmentGone, assessment_id
      end
    end
  end
end
