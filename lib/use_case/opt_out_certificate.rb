module UseCase

  class OptOutCertificate

    def initialize(eav_gateway)
      @assessment_attribute_gateway = eav_gateway
    end

    def execute(assessment_id, opt_out=true)
      @assessment_attribute_gateway.update_assessment_attribute(assessment_id, 'opt-out', opt_out ? 'true' : 'false')
    end

  end

end