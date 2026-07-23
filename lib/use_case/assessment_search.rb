module UseCase
  class AssessmentSearch
    def initialize(assessment_search_gateway:)
      @assessment_search_gateway = assessment_search_gateway
    end

    def execute(**args)
      args.delete(:eff_rating) if args[:eff_rating] && (args[:eff_rating].sort == %w[A B C D E F G])

      result = @assessment_search_gateway.fetch_assessments(**args)

      raise Boundary::NoData, "assessment search" if result.empty?

      result
    end
  end
end
