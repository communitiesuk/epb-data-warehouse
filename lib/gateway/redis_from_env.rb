module Gateway
  module RedisFromEnv
  private

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
