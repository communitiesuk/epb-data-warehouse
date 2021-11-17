# frozen_string_literal: true
require 'redis'

module Gateway
  class QueuesGateway
    class InvalidRedisQueueNameError < StandardError; end

    QUEUE_NAMES = %i[assessments cancelled opt_outs].freeze

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

    def validate_queue_name(name)
      raise InvalidRedisQueueNameError, "You can only access #{QUEUE_NAMES}" unless valid_queue_name?(name)
    end

    def valid_queue_name?(name)
      QUEUE_NAMES.include?(name.to_sym)
    end

    def redis_from_env
      if ENV.key? "EPB_QUEUES_URI"
        redis_url = ENV["EPB_QUEUES_URI"]
      else
        redis_instance_name = "dluhc-epb-redis-data-warehouse-#{ENV['STAGE']}"
        redis_url = RedisConfigurationReader.read_configuration_url(redis_instance_name)
      end

      Redis.new(url: redis_url)
    end
  end
end
