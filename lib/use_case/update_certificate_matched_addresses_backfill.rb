module UseCase
  class UpdateCertificateMatchedAddressesBackfill < UpdateCertificateMatchedAddressesBase
    def initialize(queues_gateway:, documents_gateway:, assessment_search_gateway:, recovery_list_gateway:, logger: nil)
      super
      @queue_name = :backfill_matched_address_update
    end

    def execute(from_recovery_list: false)
      payload = get_payload(from_recovery_list:)

      payload.each do |assessment|
        payload_arr = assessment.split(":")
        assessment_id = payload_arr[0]
        matched_uprn = payload_arr[1]

        if address_id_valid?(matched_uprn)
          @documents_gateway.update_matched_uprn assessment_id:, matched_uprn: matched_uprn, update: false
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
  end
end
