module UseCase
  class CancelCertificates
    include Helper::MetaDataRule

    def initialize(eav_gateway:, queues_gateway:, api_gateway:, documents_gateway:, recovery_list_gateway:, assessments_country_id_gateway:,
                   logger: nil)
      @assessment_attribute_gateway = eav_gateway
      @queues_gateway = queues_gateway
      @api_gateway = api_gateway
      @documents_gateway = documents_gateway
      @recovery_list_gateway = recovery_list_gateway
      @logger = logger
      @assessments_country_id_gateway = assessments_country_id_gateway
      @queue = :cancelled
    end

    def execute(from_recovery_list: false)
      if from_recovery_list
        assessment_ids = @recovery_list_gateway.assessments queue:
      else
        assessment_ids = @queues_gateway.consume_queue(queue: )
        register_assessments_to_recovery_list assessment_ids
      end

      assessment_ids.each do |assessment_id|
        meta_data = @api_gateway.fetch_meta_data(assessment_id)
        unless (meta_data[:cancelledAt].nil? && meta_data[:notForIssueAt].nil?) || should_exclude?(meta_data:)
          @assessment_attribute_gateway.delete_attributes_by_assessment assessment_id
          @documents_gateway.delete_assessment(assessment_id:)
          @assessments_country_id_gateway.delete_assessment(assessment_id:)
        end

        clear_assessment_from_recovery_list assessment_id
      rescue StandardError => e
        report_to_sentry e
        @logger.error "Error of type #{e.class} when importing cancellation for the RRN #{assessment_id}: '#{e.message}'" if @logger.respond_to?(:error)
        register_attempt_to_recovery_list assessment_id unless e.is_a?(Errors::ConnectionApiError)
      end
    rescue StandardError => e
      report_to_sentry e
      @logger.error "Error of type #{e.class} when importing cancellations of certificates: '#{e.message}'" if @logger.respond_to?(:error)
    end

  private
    attr_accessor :queue

    def clear_assessment_from_recovery_list(assessment_id)
      @recovery_list_gateway.clear_assessment assessment_id, queue:
    end

    def register_attempt_to_recovery_list(assessment_id)
      @recovery_list_gateway.register_attempt assessment_id:, queue:
    end

    def register_assessments_to_recovery_list(assessment_ids)
      @recovery_list_gateway.register_assessments(*assessment_ids, queue: )
    end
  end
end
