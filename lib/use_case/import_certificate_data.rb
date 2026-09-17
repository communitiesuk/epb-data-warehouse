module UseCase
  class ImportCertificateData
    AttributeValue = Struct.new :name, :value, :parent_name

    def initialize(assessment_attribute_gateway:, documents_gateway:, assessment_search_gateway:, commercial_reports_gateway:, logger: nil)
      @assessment_attribute_gateway = assessment_attribute_gateway
      @assessment_search_gateway = assessment_search_gateway
      @commercial_reports_gateway = commercial_reports_gateway
      @documents_gateway = documents_gateway
      @logger = logger
    end

    def execute(assessment_id:, certificate_data:, country_id: nil)
      save_eav_attributes(assessment_id:, certificate: certificate_data)
      @documents_gateway.add_assessment(assessment_id:, document: certificate_data)
      unless certificate_data["opt_out"]
        @assessment_search_gateway.insert_assessment(assessment_id:, document: certificate_data, country_id:)
      end
      if %w[CEPC DEC].include?(certificate_data["assessment_type"]) && certificate_data["related_rrn"]
        @commercial_reports_gateway.insert_report(assessment_id:, related_rrn: certificate_data["related_rrn"])
      end
    end

  private

    def save_eav_attributes(assessment_id:, certificate:)
      @assessment_attribute_gateway.add_attribute_values(
        *certificate.map do |key, value|
          AttributeValue.new key.to_s, value, nil
        end,
        assessment_id:,
      )
    rescue Boundary::BadAttributesWrite => e
      report_to_sentry e
    end
  end
end
