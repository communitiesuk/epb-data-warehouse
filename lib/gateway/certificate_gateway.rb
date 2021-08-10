# frozen_string_literal: true

module Gateway
  class CertificateGateway
    class AssessmentNotFound < StandardError
    end

    def initialize(api_client)
      @internal_api_client = api_client
    end

    def fetch(assessment_id)
      route = "/api/assessments/#{CGI.escape(assessment_id)}"

      response =
        Helper::Response.ensure_good { @internal_api_client.get(route) }

      response.body
    end

    def fetch_meta_data(assessment_id)
      route = "/api/assessments/#{CGI.escape(assessment_id)}/meta-data"

      response =
        Helper::Response.ensure_good { @internal_api_client.get(route) }

      JSON.parse(response.body, symbolize_names: true)[:data]

    end
  end
end
