module Helper
  class Stopwatch
    def initialize
      @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def elapsed_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time
    end

    def self.log_elapsed_time(logger, message)
      return yield unless Helper::Toggles.enabled?("data_warehouse_measures_operations") || !block_given?

      stopwatch = new
      rtn = yield if block_given?
      logger.info "#{message} in #{stopwatch.elapsed_time}s" if logger.respond_to?(:info)
      rtn if defined?(rtn)
    end
  end
end
