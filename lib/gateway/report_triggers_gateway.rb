# frozen_string_literal: true

module Gateway
  class ReportTriggersGateway
    include RedisFromEnv

    def initialize(redis_client: nil)
      @redis = redis_client || redis_from_env
    end

    def triggers
      triggers_to_process = filter_by_locks(redis.smembers("report_triggers").map(&:to_sym))
      write_locks_for_triggers triggers_to_process
      triggers_to_process
    end

    def remove_trigger(trigger)
      redis.srem "report_triggers", trigger
    end

  private

    attr_reader :redis

    TEN_MINUTES_IN_SECONDS = 600

    def lock_key_for_trigger(trigger)
      "report_triggers:#{trigger}"
    end

    def write_lock_for_trigger(trigger)
      redis.setex lock_key_for_trigger(trigger), TEN_MINUTES_IN_SECONDS, "locked" # write lock that expires after ten minutes
    end

    def write_locks_for_triggers(triggers)
      triggers.each { |trigger| write_lock_for_trigger trigger }
    end

    def filter_by_locks(triggers)
      triggers.reject { |trigger| has_lock?(trigger) }
    end

    def has_lock?(trigger)
      !!redis.get(lock_key_for_trigger(trigger))
    end
  end
end
