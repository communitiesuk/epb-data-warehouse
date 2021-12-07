module UseCase
  class CancelCertificates
    def initialize(eav_gateway:, queues_gateway:, api_gateway:, documents_gateway:, logger: nil)
      @assessment_attribute_gateway = eav_gateway
      @queues_gateway = queues_gateway
      @api_gateway = api_gateway
      @documents_gateway = documents_gateway
      @logger = logger
    end

    def execute
      assessment_ids = @queues_gateway.consume_queue(:cancelled)
      assessment_ids.each do |assessment_id|
        meta_data = @api_gateway.fetch_meta_data(assessment_id)
        next if meta_data[:cancelledAt].nil?

        @assessment_attribute_gateway.add_attribute_value assessment_id: assessment_id,
                                                          attribute_name: "cancelled_at",
                                                          attribute_value: Helper::DateTime.convert_atom_to_db_datetime(meta_data[:cancelledAt])
        @documents_gateway.set_top_level_attribute assessment_id: assessment_id,
                                                   top_level_attribute: "cancelled_at",
                                                   new_value: Helper::DateTime.convert_atom_to_db_datetime(meta_data[:cancelledAt])
      rescue StandardError => e
        report_to_sentry e
        @logger.error "Error of type #{e.class} when importing cancellation for the RRN #{assessment_id}: '#{e.message}'" if @logger.respond_to?(:error)
      end
    rescue StandardError => e
      report_to_sentry e
      @logger.error "Error of type #{e.class} when importing cancellations of certificates: '#{e.message}'" if @logger.respond_to?(:error)
    end
  end
end
