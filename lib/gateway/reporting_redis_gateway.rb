require "redis"

module Gateway
  class ReportingRedisGateway
    include RedisFromEnv

    def initialize(redis_client: nil)
      @redis = redis_client || redis_from_env
    end

    def save_report(key, data)
      report = { data:, date_created: Time.now }.to_json
      @redis.set(key, report)
    end
  end
end
