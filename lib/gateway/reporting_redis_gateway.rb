require "redis"

module Gateway
  class ReportingRedisGateway
    include RedisFromEnv

    def initialize(redis_client: nil)
      @redis = redis_client || redis_from_env
    end

    def save_report(key, report, seconds_to_expire = nil)
      seconds_to_expire.nil? ? @redis.set(key, report) : @redis.set(key, report, ex: seconds_to_expire)
    end
  end
end
