module UseCase
  class AssessmentSearch
    def initialize(assessment_search_gateway:)
      @assessment_search_gateway = assessment_search_gateway
    end

    def execute(*args)
      this_args = args[0]

      this_args.delete(:eff_rating) if this_args[:eff_rating] && (this_args[:eff_rating].sort == %w[A B C D E F G])

      raise Boundary::InvalidDates if this_args[:date_start] > this_args[:date_end]

      range = (Date.parse(this_args[:date_start])..Date.parse(this_args[:date_end]))
      raise Boundary::InvalidArgument, "date range includes today" if range.include? Date.today

      this_args[:postcode] = Helper::PostcodeValidator.validate(this_args[:postcode]) unless this_args[:postcode].nil?

      unless this_args[:council].nil?
        councils = Container.ons_gateway.councils.map { |c| c["name"] }
        this_args[:council].each do |council|
          raise Errors::CouncilNotFound, "provide valid council name(s)" unless councils.include?(council)
        end
      end

      unless this_args[:constituency].nil?
        constituencies = Container.ons_gateway.constituencies.map { |c| c["name"] }
        this_args[:constituency].each do |constituency|
          raise Errors::ConstituencyNotFound, "provide valid constituency name(s)" unless constituencies.include?(constituency)
        end
      end

      result = @assessment_search_gateway.find_assessments(**this_args)

      raise Boundary::NoData, "assessment search" if result.empty?

      result
    end
  end
end
