module UseCase
  class GetRedactedCertificate
    def initialize(documents_gateway:)
      @documents_gateway = documents_gateway
    end

    def execute(assessment_id:)
      @documents_gateway.fetch_redacted(assessment_id:)
    end
  end
end
