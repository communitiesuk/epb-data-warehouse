module UseCase
  class UpdateCertificateMatchedAddresses < UpdateCertificateMatchedAddressesBase
    include Helper::MetaDataRule
    ASSESSMENT_ADDRESS_ID_KEY = "matched_uprn".freeze

    def initialize(queues_gateway:, documents_gateway:, certificate_gateway:, assessment_search_gateway:, recovery_list_gateway:, logger: nil)
      super(queues_gateway:, documents_gateway:, assessment_search_gateway:, recovery_list_gateway:, logger:)
      @certificate_gateway = certificate_gateway
      @queue_name = :matched_address_update
    end

    def execute(from_recovery_list: false)
      payload = get_payload(from_recovery_list:)

      payload.each do |assessment|
        payload_arr = assessment.split(":")
        assessment_id = payload_arr[0]
        matched_uprn = payload_arr[1]

        if address_id_valid?(matched_uprn)
          meta_data = @certificate_gateway.fetch_meta_data(assessment_id)
          unless meta_data.nil? || should_exclude?(meta_data:) || is_green_deal?(meta_data:) || is_cancelled?(meta_data:)

            check_assessment_search = meta_data[:typeOfAssessment] != "AC-CERT" && Gateway::AssessmentSearchGateway::VALID_COUNTRY_IDS.include?(meta_data[:countryId])

            if @documents_gateway.check_id_exists?(assessment_id: assessment_id, include_search_table: check_assessment_search)
              @documents_gateway.set_top_level_attribute assessment_id:, top_level_attribute: ASSESSMENT_ADDRESS_ID_KEY, new_value: matched_uprn, update: true
              if check_assessment_search
                @assessment_search_gateway.update_uprn assessment_id:, new_value: matched_uprn, override: false
              end
            else
              raise "Assessment with id #{assessment_id} not imported yet, waiting for longer"
            end
          end
        end
        clear_assessment_on_recovery_list payload: assessment
      rescue StandardError => e
        report_to_sentry e if is_on_last_attempt(payload: assessment)
        @logger.error "Error of type #{e.class} when updating an EPC matched_uprn for #{assessment}: '#{e.message}'" if @logger.respond_to?(:error)
        register_attempt_to_recovery_list payload: assessment unless e.is_a?(Errors::ConnectionApiError)
      end
    rescue StandardError => e
      report_to_sentry e
      @logger.error "Error of type #{e.class} when updating matched_uprn on certificates: '#{e.message}'" if @logger.respond_to?(:error)
    end

  private

    def register_assessments_to_recovery_list(assessment_ids)
      @recovery_list_gateway.register_assessments(*assessment_ids, queue: @queue_name, retries: 50)
    end
  end
end
