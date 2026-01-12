module Controller
  class CertificateController < Controller::BaseController
    CERTIFICATE_SCHEMA = {
      type: "object",
      required: %w[certificate_number],
      properties: {
        certificate_number: {
          type: "string",
        },
      },
    }.freeze

    get "/api/certificate" do
      @camel_case_keys = false
      params_body CERTIFICATE_SCHEMA
      use_case = Container.get_redacted_certificate_use_case
      result = use_case.execute(assessment_id: params[:certificate_number])
      json_api_response code: 200, data: result
    rescue Errors::CertificateNotFound
      no_certificate_error = "Certificate not found"
      json_api_response code: 404, data: { error: no_certificate_error }
    rescue StandardError => e
      report_to_sentry(e)
      json_api_response code: 500, data: { errors: [{ code: e.message }] }
    end
  end
end
