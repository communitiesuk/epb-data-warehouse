module Gateway
  module QueueNames
    class InvalidNameError < StandardError; end

    QUEUE_NAMES = %i[assessments cancelled opt_outs assessments_address_update matched_address_update backfill_matched_address_update].freeze

  private

    def validate_queue_name(name)
      raise InvalidNameError, "You can only access #{QUEUE_NAMES}" unless valid_queue_name?(name)
    end

    def valid_queue_name?(name)
      QUEUE_NAMES.include?(name.to_sym)
    end
  end
end
