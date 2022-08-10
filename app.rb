require "active_support"
require "active_support/core_ext"
require "active_record"
require "async"
require "redis"
require "zeitwerk"
require "concurrent"
require "sentry-ruby"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib")
loader.setup

Sentry.init do |config|
  config.environment = ENV["STAGE"]
  config.capture_exception_frame_locals = true
  config.sample_rate = 0.001
end

def use_case(name)
  Services.use_case name
end

def gateway(name)
  Services.gateway name
end

def report_to_sentry(exception)
  Sentry.capture_exception(exception) if defined?(Sentry)
end

class QueueWorker
  def start!
    loop do
      register_signal_handlers
      set_postgres_connection
      pull_queues

      sleep 1
    end
  rescue Interrupt
    shutdown
  end

private

  def pull_queues
    Helper::Toggles.enabled?("data_warehouse_consumes_queues", default: true) do
      pull_use_case = use_case :pull_queues
      pull_use_case.execute from_recovery_list: true
      pull_use_case.execute from_recovery_list: false
    end
  end

  def register_signal_handlers
    trap("INT") { interrupt }
    trap("TERM") { interrupt }
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
