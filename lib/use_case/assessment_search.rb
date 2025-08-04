module UseCase
  class AssessmentSearch
    def initialize(assessment_search_gateway:)
      @assessment_search_gateway = assessment_search_gateway
    end

    def execute(*args)
      this_args = args[0]

      this_args.delete(:eff_rating) if this_args[:eff_rating] && (this_args[:eff_rating].sort == %w[A B C D E F G])

      result = @assessment_search_gateway.fetch_assessments(**this_args)

      raise Boundary::NoData, "assessment search" if result.empty?

      result
    end
  end
end
