module UseCase
  class UpdateCertificateAddresses
    def initialize(eav_gateway:, queues_gateway:, documents_gateway:, recovery_list_gateway:, logger: nil)
      @assessment_attribute_gateway = eav_gateway
      @queues_gateway = queues_gateway
      @documents_gateway = documents_gateway
      @recovery_list_gateway = recovery_list_gateway
      @logger = logger
      @queue = :assessments_address_update
    end

    def execute(from_recovery_list: false)
      if from_recovery_list
        payload = @recovery_list_gateway.assessments queue:
      else
        payload = @queues_gateway.consume_queue(queue:)
        register_assessments_to_recovery_list payload
      end
      top_level_attribute = "assessment_address_id"

      payload.each do |assessment|
        payload_arr = assessment.split(":")
        assessment_id = payload_arr[0]
        address_id = payload_arr[1]
        @documents_gateway.set_top_level_attribute assessment_id:, top_level_attribute:, new_value: address_id
        @assessment_attribute_gateway.update_assessment_attribute assessment_id:, attribute: top_level_attribute, value: address_id
        clear_assessment_on_recovery_list payload: assessment
      rescue StandardError => e
        report_to_sentry e
        @logger.error "Error of type #{e.class} when updating an EPC address using #{assessment}: '#{e.message}'" if @logger.respond_to?(:error)
        register_attempt_to_recovery_list payload: assessment unless e.is_a?(Errors::ConnectionApiError)
      end
    rescue StandardError => e
      report_to_sentry e
      @logger.error "Error of type #{e.class} when updating EPC address_ids certificates: '#{e.message}'" if @logger.respond_to?(:error)
    end

  private

    attr_accessor :queue

    def clear_assessment_on_recovery_list(payload:)
      @recovery_list_gateway.clear_assessment payload:, queue:
    end

    def register_attempt_to_recovery_list(payload:)
      @recovery_list_gateway.register_attempt payload:, queue:
    end

    def register_assessments_to_recovery_list(assessment_ids)
      @recovery_list_gateway.register_assessments(*assessment_ids, queue:)
    end
  end
end
