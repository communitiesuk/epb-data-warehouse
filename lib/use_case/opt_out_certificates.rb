module UseCase
  class OptOutCertificates
    include Helper::MetaDataRule

    OPT_OUT = "opt_out".freeze
    OPT_IN = "opt_in".freeze

    def initialize(eav_gateway:, documents_gateway:, queues_gateway:, certificate_gateway:, recovery_list_gateway:, logger: nil)
      @assessment_attribute_gateway = eav_gateway
      @documents_gateway = documents_gateway
      @queues_gateway = queues_gateway
      @certificate_gateway = certificate_gateway
      @recovery_list_gateway = recovery_list_gateway
      @logger = logger
    end

    def execute(from_recovery_list: false)
      if from_recovery_list
        assessment_ids = @recovery_list_gateway.assessments queue: :opt_outs
      else
        assessment_ids = @queues_gateway.consume_queue(:opt_outs)
        register_assessments_to_recovery_list assessment_ids
      end

      assessment_ids.each do |assessment_id|
        meta_data = @certificate_gateway.fetch_meta_data(assessment_id)
        unless should_exclude?(meta_data: meta_data)
          if meta_data[:optOut]
            save_attribute_to_stores assessment_id: assessment_id,
                                     attribute: OPT_OUT,
                                     value: now_in_db_format
          else
            delete_attribute_from_stores assessment_id: assessment_id,
                                         attribute: OPT_OUT

            save_attribute_to_stores assessment_id: assessment_id,
                                     attribute: OPT_IN,
                                     value: now_in_db_format
          end
        end

        clear_assessment_on_recovery_list assessment_id
      rescue StandardError => e
        report_to_sentry e
        @logger.error "Error of type #{e.class} when importing change of opt-out status for RRN #{assessment_id}: '#{e.message}'" if @logger.respond_to?(:error)
        register_attempt_to_recovery_list assessment_id
      end
    rescue StandardError => e
      report_to_sentry e
      @logger.error "Error of type #{e.class} when importing changes of opt-out status: '#{e.message}'" if @logger.respond_to?(:error)
    end

  private

    def save_attribute_to_stores(assessment_id:, attribute:, value:)
      @assessment_attribute_gateway.delete_attribute_value(assessment_id: assessment_id, attribute_name: attribute)
      @assessment_attribute_gateway.add_attribute_value(assessment_id: assessment_id, attribute_name: attribute, attribute_value: value)
      @documents_gateway.set_top_level_attribute(assessment_id: assessment_id, top_level_attribute: attribute, new_value: value)
    end

    def delete_attribute_from_stores(assessment_id:, attribute:)
      @assessment_attribute_gateway.delete_attribute_value(assessment_id: assessment_id, attribute_name: attribute)
      @documents_gateway.delete_top_level_attribute(assessment_id: assessment_id, top_level_attribute: attribute)
    end

    def now_in_db_format
      Time.now.utc.strftime("%F %T")
    end

    def clear_assessment_on_recovery_list(assessment_id)
      @recovery_list_gateway.clear_assessment assessment_id, queue: :opt_outs
    end

    def register_attempt_to_recovery_list(assessment_id)
      @recovery_list_gateway.register_attempt assessment_id: assessment_id, queue: :opt_outs
    end

    def register_assessments_to_recovery_list(assessment_ids)
      @recovery_list_gateway.register_assessments(*assessment_ids, queue: :opt_outs)
    end
  end
end
