module UseCase
  class OptOutCertificate
    OPT_OUT = "opt_out".freeze

    def initialize(eav_gateway, redis_gateway, certificate_gateway)
      @assessment_attribute_gateway = eav_gateway
      @redis_gateway = redis_gateway
      @certificate_gateway = certificate_gateway
    end

    def execute
      assessment_ids = @redis_gateway.consume_queue "opt-out"
      assessment_ids.each do |assessment_id|
        meta_data = @certificate_gateway.fetch_meta_data(assessment_id)
        if meta_data[:optOut]
          @assessment_attribute_gateway.add_attribute_value(assessment_id: assessment_id, attribute_name: OPT_OUT, attribute_value: true)
        else
          @assessment_attribute_gateway.delete_attribute_value(assessment_id: assessment_id, attribute_name: OPT_OUT)
          @assessment_attribute_gateway.add_attribute_value(assessment_id: assessment_id, attribute_name: "opt_in", attribute_value: Time.now)
        end
      end
    end
  end
end
