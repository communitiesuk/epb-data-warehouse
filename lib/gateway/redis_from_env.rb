module Gateway
  module RedisFromEnv
  private

    def redis_from_env
      redis_url = if ENV.key? "EPB_QUEUES_URI"
                    ENV["EPB_QUEUES_URI"]
                  else
                    raise "Redis cannot be connected to as ENV['EPB_QUEUES_URI'] is undefined "
                  end

      Redis.new(url: redis_url)
    end
  end
end
