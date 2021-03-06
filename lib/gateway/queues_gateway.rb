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
      redis.pipelined do |pipeline|
        count.to_i.times { futures << pipeline.rpop(queue_name.to_s) }
      end
      futures.map(&:value).compact
    end

    def push_to_queue(queue_name, data, jump_queue: false)
      validate_queue_name(queue_name)
      redis.send(jump_queue ? :rpush : :lpush, queue_name.to_s, data)
    end

  private

    attr_reader :redis
  end
end
