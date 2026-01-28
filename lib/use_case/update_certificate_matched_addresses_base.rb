module UseCase
  class UpdateCertificateMatchedAddressesBase
    def initialize(queues_gateway:, documents_gateway:, assessment_search_gateway:, recovery_list_gateway:, logger: nil)
      @queues_gateway = queues_gateway
      @documents_gateway = documents_gateway
      @assessment_search_gateway = assessment_search_gateway
      @recovery_list_gateway = recovery_list_gateway
      @logger = logger
      @queue_name = nil
    end

  private

    def address_id_valid?(matched_uprn)
      only_digits_pattern = /\A\d+\z/
      matched_uprn.match?(only_digits_pattern)
    end

    def clear_assessment_on_recovery_list(payload:)
      @recovery_list_gateway.clear_assessment payload:, queue: @queue_name
    end

    def get_payload(from_recovery_list:)
      if from_recovery_list
        payload = @recovery_list_gateway.assessments queue: @queue_name
      else
        payload = @queues_gateway.consume_queue(@queue_name)
        register_assessments_to_recovery_list payload
      end
      payload
    end

    def register_attempt_to_recovery_list(payload:)
      @recovery_list_gateway.register_attempt payload:, queue: @queue_name
    end

    def register_assessments_to_recovery_list(assessment_ids)
      @recovery_list_gateway.register_assessments(*assessment_ids, queue: @queue_name)
    end
  end
end
