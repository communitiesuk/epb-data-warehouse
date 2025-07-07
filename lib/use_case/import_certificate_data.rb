module UseCase
  class ImportCertificateData
    AttributeValue = Struct.new :name, :value, :parent_name

    def initialize(assessment_attribute_gateway:, documents_gateway:, assessment_search_gateway:, logger: nil)
      @assessment_attribute_gateway = assessment_attribute_gateway
      @assessment_search_gateway = assessment_search_gateway
      @documents_gateway = documents_gateway
      @logger = logger
    end

    def execute(assessment_id:, certificate_data:, country_id: nil)
      save_eav_attributes(assessment_id:, certificate: certificate_data)
      save_document_data(assessment_id:, certificate: certificate_data)
      save_assessment_search_data(assessment_id:, certificate: certificate_data, country_id:)
    end

  private

    attr_accessor :assessment_attribute_gateway, :documents_gateway, :assessment_search_gateway

    def save_eav_attributes(assessment_id:, certificate:)
      assessment_attribute_gateway.add_attribute_values(
        *certificate.map do |key, value|
          AttributeValue.new key.to_s, value, nil
        end,
        assessment_id:,
      )
    rescue Boundary::BadAttributesWrite => e
      report_to_sentry e
    end

    def save_document_data(assessment_id:, certificate:)
      documents_gateway.add_assessment(assessment_id:, document: certificate)
    end

    def save_assessment_search_data(assessment_id:, certificate:, country_id:)
      assessment_search_gateway.insert_assessment(assessment_id:, document: certificate, country_id:)
    end
  end
end
