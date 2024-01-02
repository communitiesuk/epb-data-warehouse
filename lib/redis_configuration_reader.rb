class RedisConfigurationReader
  LOCAL_URL = "redis://127.0.0.1:6379".freeze

  def self.read_configuration_url
    LOCAL_URL
  end
end
