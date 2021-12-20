# frozen_string_literal: true

require "redis"

module Gateway
  class QueuesGateway
    include QueueNames
    include RedisFromEnv

    def initialize(redis_client: nil)
      @redis = redis_client || redis_from_env
    end

    def consume_queue(queue_name, count: 50)
      validate_queue_name(queue_name)

      futures = []
      redis.pipelined do
        count.to_i.times { futures << redis.rpop(queue_name.to_s) }
      end
      futures.map(&:value).compact
    end

    def push_to_queue(queue_name, data)
      validate_queue_name(queue_name)
      redis.lpush(queue_name.to_s, data)
    end

  private

    attr_reader :redis
  end
end
