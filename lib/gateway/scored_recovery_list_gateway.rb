require "redis"

module Gateway
  class ScoredRecoveryListGateway
    include QueueNames
    include RedisFromEnv

    VISIBILITY_TIMEOUT = 120

    def initialize(redis_client: nil)
      @redis = redis_client || redis_from_env
    end

    def assessments(queue:, batch_size: 50)
      validate_queue_name queue
      redis.eval(
        <<~LUA,
          local queue_key = KEYS[1]
          local now = tonumber(ARGV[1])
          local timeout = tonumber(ARGV[2])
          local limit = tonumber(ARGV[3])
          local next_visible_at = now + timeout

          local items = redis.call('ZRANGEBYSCORE', queue_key, '-inf', now, 'LIMIT', 0, limit)

          if #items > 0 then
            local args = {}
            for i, item in ipairs(items) do
              table.insert(args, next_visible_at)
              table.insert(args, item)
            end
            redis.call('ZADD', queue_key, unpack(args))
          end
          return items
        LUA
        keys: [name_for_queue_scored(queue)],
        argv: [Time.now.to_f, VISIBILITY_TIMEOUT, batch_size],
      )
    end

    def register_assessments(*assessment_ids, queue:, retries: 3)
      validate_queue_name queue
      return if assessment_ids.empty?

      redis.hset(name_for_queue(queue), *assessment_ids.map { |id| [id, retries] }.flatten)

      current_time = Time.now.to_f
      zadd_args = assessment_ids.flat_map { |id| [current_time, id] }
      redis.zadd(name_for_queue_scored(queue), zadd_args)
    end

    # 3. SUCCESS (Remove)
    def clear_assessment(payload:, queue:)
      validate_queue_name queue
      redis.pipelined do |pipeline|
        pipeline.zrem(name_for_queue_scored(queue), payload)
        pipeline.hdel(name_for_queue(queue), payload)
      end
    end

    # 4. FAILURE (Retry or Remove)
    def register_attempt(payload:, queue:)
      validate_queue_name queue
      redis.eval(
        <<~LUA,
          local hash_key = KEYS[1]
          local zset_key = KEYS[2]
          local payload = ARGV[1]
          local now = tonumber(ARGV[2])

          local attempts = redis.call('HGET', hash_key, payload)

          if not attempts or tonumber(attempts) <= 1 then
            redis.call('HDEL', hash_key, payload)
            redis.call('ZREM', zset_key, payload)
          else
            redis.call('HINCRBY', hash_key, payload, -1)
            redis.call('ZADD', zset_key, now, payload)
          end
        LUA
        keys: [name_for_queue(queue), name_for_queue_scored(queue)],
        argv: [payload, Time.now.to_f],
      )
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

    def name_for_queue_scored(queue)
      "#{queue}_recovery_scored"
    end
  end
end
