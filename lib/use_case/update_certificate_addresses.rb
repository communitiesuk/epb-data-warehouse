module UseCase
  class UpdateCertificateAddresses
    ASSESSMENT_ADDRESS_ID_KEY = "assessment_address_id".freeze

    def initialize(eav_gateway:, queues_gateway:, documents_gateway:, recovery_list_gateway:, logger: nil)
      @assessment_attribute_gateway = eav_gateway
      @queues_gateway = queues_gateway
      @documents_gateway = documents_gateway
      @recovery_list_gateway = recovery_list_gateway
      @logger = logger
      @queue_name = :assessments_address_update
    end

    def execute(from_recovery_list: false)
      if from_recovery_list
        payload = @recovery_list_gateway.assessments queue: @queue_name
      else
        payload = @queues_gateway.consume_queue(@queue_name)
        register_assessments_to_recovery_list payload
      end

      payload.each do |assessment|
        payload_arr = assessment.split(":")
        assessment_id = payload_arr[0]
        address_id = payload_arr[1]
        @documents_gateway.set_top_level_attribute assessment_id:, top_level_attribute: ASSESSMENT_ADDRESS_ID_KEY, new_value: address_id
        @assessment_attribute_gateway.update_assessment_attribute assessment_id:, attribute: ASSESSMENT_ADDRESS_ID_KEY, value: address_id
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

    def clear_assessment_on_recovery_list(payload:)
      @recovery_list_gateway.clear_assessment payload:, queue: @queue_name
    end

    def register_attempt_to_recovery_list(payload:)
      @recovery_list_gateway.register_attempt payload:, queue: @queue_name
    end

    def register_assessments_to_recovery_list(assessment_ids)
      @recovery_list_gateway.register_assessments(*assessment_ids, queue: @queue_name)
    end
  end
end
