module UseCase
  class AssessmentSearch
    def initialize(assessment_search_gateway:)
      @assessment_search_gateway = assessment_search_gateway
    end

    def execute(*args)
      this_args = args[0]
      raise Boundary::InvalidDates if this_args[:date_start] > this_args[:date_end]

      range = (Date.parse(this_args[:date_start])..Date.parse(this_args[:date_end]))
      raise Boundary::InvalidArgument, "date range includes today" if range.include? Date.today

      @assessment_search_gateway.find_assessments(**this_args)
    end
  end
end
