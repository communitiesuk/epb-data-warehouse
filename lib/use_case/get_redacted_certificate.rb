module UseCase
  class GetRedactedCertificate
    def initialize(documents_gateway:)
      @documents_gateway = documents_gateway
    end

    def execute(assessment_id:)
      redacted_document = @documents_gateway.fetch_by_id(assessment_id:)
      raise Errors::CertificateNotFound if redacted_document.nil?

      redacted_document
    end
  end
end
