module UseCase
  class CountCertificates
    def initialize(assessment_search_gateway:)
      @assessment_search_gateway = assessment_search_gateway
    end

    def execute(*args)
      this_args = args[0]

      if !this_args[:eff_rating].nil? && this_args[:eff_rating].sort == %w[A B C D E F G]
        this_args.delete(:eff_rating)
      end
      @assessment_search_gateway.count(**this_args)
    end
  end
end
