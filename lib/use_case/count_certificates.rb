module UseCase
  class CountCertificates
    def initialize(assessment_search_gateway:)
      @assessment_search_gateway = assessment_search_gateway
    end

    def execute(**args)
      if !args[:eff_rating].nil? && args[:eff_rating].sort == %w[A B C D E F G]
        args.delete(:eff_rating)
      end
      @assessment_search_gateway.count(**args)
    end
  end
end
