module Gateway
  module QueueNames
    class InvalidNameError < StandardError; end

    QUEUE_NAMES = %i[assessments cancelled opt_outs].freeze

  private

    def validate_queue_name(name)
      raise InvalidNameError, "You can only access #{QUEUE_NAMES}" unless valid_queue_name?(name)
    end

    def valid_queue_name?(name)
      QUEUE_NAMES.include?(name.to_sym)
    end
  end
end
