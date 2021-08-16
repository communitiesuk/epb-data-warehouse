class RedisConfigurationReader
  LOCAL_URL = "redis://127.0.0.1:6379".freeze

  def self.read_configuration_url(instance_name)
    unless ENV["VCAP_SERVICES"].nil?
      vcap_services = JSON.parse(ENV["VCAP_SERVICES"], symbolize_names: true)

      unless vcap_services[:redis].nil?
        vcap_services[:redis].each do |config|
          if config[:instance_name] == instance_name
            return config.dig(:credentials, :uri)
          end
        end
      end

    end

    LOCAL_URL
  end
end
