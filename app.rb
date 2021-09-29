require "active_record"
require "active_support"
require "active_support/core_ext/uri"
require "redis"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib")
loader.setup

class QueueWorker
  def start!
    loop do
      register_signal_handlers
      set_postgres_connection
      set_redis_connection
      pull_queues

      sleep 5
    end
  rescue Interrupt
    shutdown
  end

private

  def pull_queues
    ids = @redis_gateway.consume_queue(:temp_queue)
    unless ids.empty?
      pp ids
    end
  end

  def register_signal_handlers
    trap("INT") { interrupt }
    trap("TERM") { interrupt }
  end

  def set_redis_connection
    redis_instance_name = "mhclg-epb-redis-data-warehouse-#{environment}"
    redis_url = RedisConfigurationReader.read_configuration_url(redis_instance_name)
    @redis_gateway = Gateway::RedisGateway.new(redis_client: Redis.new(url: redis_url))
  end

  def set_postgres_connection
    if ENV["DATABASE_URL"].nil?
      raise ArgumentError, "Please set DATABASE_URL"
    end

    # DATABASE_URL is defined by default on GOV PaaS if there is a bound PostgreSQL database
    ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
  end

  def environment
    ENV["STAGE"]
  end

  def interrupt
    raise Interrupt
  end

  def shutdown
    puts "Shutting down queue worker"
    exit(0)
  end
end

QueueWorker.new.start!
