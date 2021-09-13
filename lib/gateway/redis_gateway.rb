# frozen_string_literal: true

module Gateway
  class RedisGateway
    def initialize(redis_client: nil)
      @redis = redis_client || Redis.new
    end

    def consume_queue(queue_name, count: 50)
      futures = []
      redis.pipelined do
        count.to_i.times { futures << redis.rpop(queue_name.to_s) }
      end
      futures.map(&:value).compact
    end

    def push_to_queue(queue_name, data)
      redis.lpush(queue_name.to_s, data)
    end

  private

    attr_reader :redis
  end
end
