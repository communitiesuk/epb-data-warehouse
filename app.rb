require "active_record"
require "active_support"
require "active_support/core_ext/uri"
require "redis"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib")
loader.setup

def use_case(name)
  Services.use_case name
end

def gateway(name)
  Services.gateway name
end

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
    use_case(:pull_queues).execute
  end

  def register_signal_handlers
    trap("INT") { interrupt }
    trap("TERM") { interrupt }
  end

  def set_redis_connection
    @queues_gateway = gateway :queues
  end

  def set_postgres_connection
    if ENV["DATABASE_URL"].nil?
      raise ArgumentError, "Please set DATABASE_URL"
    end

    # DATABASE_URL is defined by default on GOV PaaS if there is a bound PostgreSQL database
    ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
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
