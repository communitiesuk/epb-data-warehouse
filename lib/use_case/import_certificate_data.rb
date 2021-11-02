module UseCase
  class ImportCertificateData
    attr_accessor :assessment_attribute_gateway

    def initialize(assessment_attribute_gateway:)
      @assessment_attribute_gateway = assessment_attribute_gateway
    end

    def execute(assessment_id:, certificate_data:)
      save_attributes(assessment_id, certificate_data)
    end

    def save_attributes(assessment_id, certificate, parent_name = nil)
      certificate.each do |key, value|
        value = JSON.generate(value) if value.instance_of?(Hash) || value.instance_of?(Array)

        attribute = {
          attribute: key.to_s,
          value: value,
          assessment_id: assessment_id,
          parent_name: parent_name,
        }
        save_attribute_data(attribute)
      end
    end

  private

    def save_attribute_data(attribute)
      @assessment_attribute_gateway.add_attribute_value(
        assessment_id: attribute[:assessment_id],
        attribute_name: attribute[:attribute],
        attribute_value: attribute[:value],
        parent_name: attribute[:parent_name],
      )
    end
  end
end
