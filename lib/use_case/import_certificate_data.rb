module UseCase
  class ImportCertificateData
    def initialize(assessment_attribute_gateway:, documents_gateway:)
      @assessment_attribute_gateway = assessment_attribute_gateway
      @documents_gateway = documents_gateway
    end

    def execute(assessment_id:, certificate_data:)
      save_eav_attributes(assessment_id: assessment_id, certificate: certificate_data)
      save_document_data(assessment_id: assessment_id, certificate: certificate_data)
    end

  private

    attr_accessor :assessment_attribute_gateway, :documents_gateway

    def save_eav_attributes(assessment_id:, certificate:)
      certificate.each do |key, value|
        # value = value if value.instance_of?(Hash) || value.instance_of?(Array)

        attribute = {
          attribute: key.to_s,
          value: value,
          assessment_id: assessment_id,
          parent_name: nil,
        }
        save_eav_attribute_data(**attribute)
      end
    end

    def save_eav_attribute_data(assessment_id:, attribute:, value:, parent_name:)
      assessment_attribute_gateway.add_attribute_value(
        assessment_id: assessment_id,
        attribute_name: attribute,
        attribute_value: value,
        parent_name: parent_name,
      )
    end

    def save_document_data(assessment_id:, certificate:)
      documents_gateway.add_assessment(assessment_id: assessment_id, document: certificate)
    end
  end
end
