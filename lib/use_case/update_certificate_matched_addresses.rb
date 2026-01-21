module UseCase
  class UpdateCertificateMatchedAddresses
    ASSESSMENT_ADDRESS_ID_KEY = "matched_uprn".freeze

    def initialize(queues_gateway:, documents_gateway:, assessment_search_gateway:, recovery_list_gateway:, queue_name:, logger: nil)
      @queues_gateway = queues_gateway
      @documents_gateway = documents_gateway
      @assessment_search_gateway = assessment_search_gateway
      @recovery_list_gateway = recovery_list_gateway
      @logger = logger
      @queue_name = queue_name
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
        matched_uprn = payload_arr[1]
        update_document = @queue_name == :matched_address_update

        if address_id_valid?(matched_uprn)
          @documents_gateway.set_top_level_attribute assessment_id:, top_level_attribute: ASSESSMENT_ADDRESS_ID_KEY, new_value: matched_uprn, update: update_document
          @assessment_search_gateway.update_uprn assessment_id:, new_value: matched_uprn, override: false
        end
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

    def address_id_valid?(matched_uprn)
      only_digits_pattern = /\A\d+\z/
      matched_uprn.match?(only_digits_pattern)
    end

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
