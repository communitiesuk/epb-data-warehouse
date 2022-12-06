# frozen_string_literal: true

module UseCase
  class RunReportsFromTriggers
    def initialize(report_triggers_gateway:, report_use_cases:, logger:)
      @report_triggers_gateway = report_triggers_gateway
      @report_use_cases = report_use_cases
      @logger = logger
    end

    def execute
      triggers = report_triggers_gateway.triggers
      triggers.each do |trigger|
        next unless report_use_cases.key?(trigger)

        begin
          report_use_cases[trigger].execute
        rescue StandardError
          logger.error "Report query for '#{trigger}' failed."
        end
        report_triggers_gateway.remove_trigger(trigger)
      end
    end

  private

    attr_reader :report_triggers_gateway, :report_use_cases, :logger
  end
end
