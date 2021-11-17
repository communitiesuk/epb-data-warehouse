module UseCase
  class CancelCertificates
    def initialize(eav_gateway:, queues_gateway:, api_gateway:)
      @assessment_attribute_gateway = eav_gateway
      @queues_gateway = queues_gateway
      @api_gateway = api_gateway
    end

    def execute
      assessment_ids = @queues_gateway.consume_queue(:cancelled)
      assessment_ids.each do |assessment_id|
        meta_data = @api_gateway.fetch_meta_data(assessment_id)
        next if meta_data[:cancelledAt].nil?

        @assessment_attribute_gateway.add_attribute_value(assessment_id: assessment_id, attribute_name: "cancelled_at", attribute_value: meta_data[:cancelledAt])
      end
    end
  end
end
