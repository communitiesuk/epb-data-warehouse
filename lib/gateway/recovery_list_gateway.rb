require "redis"

module Gateway
  class RecoveryListGateway
    include QueueNames
    include RedisFromEnv

    def initialize(redis_client: nil)
      @redis = redis_client || redis_from_env
    end

    def assessments(queue:)
      validate_queue_name queue
      redis.hkeys(name_for_queue(queue))
    end

    def clear_assessment(payload:, queue:)
      validate_queue_name queue
      redis.hdel(name_for_queue(queue), payload)
    end

    def register_attempt(payload:, queue:)
      validate_queue_name queue
      redis.eval(
        "local assessments = redis.call('HGET', KEYS[1], ARGV[1]); if not assessments or tonumber(assessments) <= 1 then redis.call('HDEL', KEYS[1], ARGV[1]) else redis.call('HINCRBY', KEYS[1], ARGV[1], -1) end",
        keys: [name_for_queue(queue)],
        argv: [payload],
      )
    end

    def register_assessments(*assessment_ids, queue:, retries: 3)
      validate_queue_name queue
      return if assessment_ids.empty?

      redis.hset(name_for_queue(queue), *assessment_ids.map { |assessment_id| [assessment_id, retries] }.flatten)
    end

    def retries_left(payload:, queue:)
      validate_queue_name queue
      redis.hget(name_for_queue(queue), payload).to_i
    end

  private

    attr_reader :redis

    def name_for_queue(queue)
      "#{queue}_recovery"
    end
  end
end
