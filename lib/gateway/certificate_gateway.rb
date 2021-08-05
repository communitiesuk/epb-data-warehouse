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
  end
end
