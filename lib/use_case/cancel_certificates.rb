module UseCase
  class CancelCertificates
    include Helper::MetaDataRule

    def initialize(eav_gateway:, queues_gateway:, api_gateway:, documents_gateway:, recovery_list_gateway:, logger: nil)
      @assessment_attribute_gateway = eav_gateway
      @queues_gateway = queues_gateway
      @api_gateway = api_gateway
      @documents_gateway = documents_gateway
      @recovery_list_gateway = recovery_list_gateway
      @logger = logger
    end

    def execute(from_recovery_list: false)
      if from_recovery_list
        assessment_ids = @recovery_list_gateway.assessments queue: :cancelled
      else
        assessment_ids = @queues_gateway.consume_queue(:cancelled)
        register_assessments_to_recovery_list assessment_ids
      end

      assessment_ids.each do |assessment_id|
        meta_data = @api_gateway.fetch_meta_data(assessment_id)
        unless meta_data[:cancelledAt].nil? || should_exclude?(meta_data: meta_data)
          @assessment_attribute_gateway.add_attribute_value assessment_id: assessment_id,
                                                            attribute_name: "cancelled_at",
                                                            attribute_value: Helper::DateTime.convert_atom_to_db_datetime(meta_data[:cancelledAt])
          @documents_gateway.set_top_level_attribute assessment_id: assessment_id,
                                                     top_level_attribute: "cancelled_at",
                                                     new_value: Helper::DateTime.convert_atom_to_db_datetime(meta_data[:cancelledAt])
        end

        clear_assessment_from_recovery_list assessment_id
      rescue StandardError => e
        report_to_sentry e
        @logger.error "Error of type #{e.class} when importing cancellation for the RRN #{assessment_id}: '#{e.message}'" if @logger.respond_to?(:error)
        register_attempt_to_recovery_list assessment_id
      end
    rescue StandardError => e
      report_to_sentry e
      @logger.error "Error of type #{e.class} when importing cancellations of certificates: '#{e.message}'" if @logger.respond_to?(:error)
    end

  private

    def clear_assessment_from_recovery_list(assessment_id)
      @recovery_list_gateway.clear_assessment assessment_id, queue: :cancelled
    end

    def register_attempt_to_recovery_list(assessment_id)
      @recovery_list_gateway.register_attempt assessment_id: assessment_id, queue: :cancelled
    end

    def register_assessments_to_recovery_list(assessment_ids)
      @recovery_list_gateway.register_assessments(*assessment_ids, queue: :cancelled)
    end
  end
end
