module Controller
  class CertificateController < Controller::BaseController
    CERTIFICATE_SCHEMA = {
      type: "object",
      required: %w[certificate_number],
      properties: {
        certificate_number: {
          type: "string",
          pattern: '^\d{4}-?\d{4}-?\d{4}-?\d{4}-?\d{4}$',
        },
      },
    }.freeze

    get "/api/certificate", has_bearer_token: true do
      params_body CERTIFICATE_SCHEMA
      use_case = Container.get_redacted_certificate_use_case
      result = use_case.execute(assessment_id: params[:certificate_number])
      json_api_response code: 200, data: result, camel_case: false
    rescue Errors::CertificateNotFound
      no_certificate_error = "Certificate not found"
      json_api_response code: 404, data: { error: no_certificate_error }
    rescue Boundary::Json::ValidationError
      json_api_response code: 400, data: { error: "Invalid certificate number" }
    end
  end
end
