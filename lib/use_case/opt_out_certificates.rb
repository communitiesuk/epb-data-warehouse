module UseCase
  class OptOutCertificates
    OPT_OUT = "opt_out".freeze
    OPT_IN = "opt_in".freeze

    def initialize(eav_gateway:, documents_gateway:, queues_gateway:, certificate_gateway:)
      @assessment_attribute_gateway = eav_gateway
      @documents_gateway = documents_gateway
      @queues_gateway = queues_gateway
      @certificate_gateway = certificate_gateway
    end

    def execute
      assessment_ids = @queues_gateway.consume_queue(:opt_outs)
      assessment_ids.each do |assessment_id|
        meta_data = @certificate_gateway.fetch_meta_data(assessment_id)
        if meta_data[:optOut]
          save_attribute_to_stores assessment_id: assessment_id,
                                   attribute: OPT_OUT,
                                   value: Time.now.utc
        else
          delete_attribute_from_stores assessment_id: assessment_id,
                                       attribute: OPT_OUT

          save_attribute_to_stores assessment_id: assessment_id,
                                   attribute: OPT_IN,
                                   value: Time.now.utc
        end
      end
    end

  private

    def save_attribute_to_stores(assessment_id:, attribute:, value:)
      @assessment_attribute_gateway.add_attribute_value(assessment_id: assessment_id, attribute_name: attribute, attribute_value: value)
      @documents_gateway.set_top_level_attribute(assessment_id: assessment_id, top_level_attribute: attribute, new_value: value)
    end

    def delete_attribute_from_stores(assessment_id:, attribute:)
      @assessment_attribute_gateway.delete_attribute_value(assessment_id: assessment_id, attribute_name: attribute)
      @documents_gateway.delete_top_level_attribute(assessment_id: assessment_id, top_level_attribute: attribute)
    end
  end
end
