module UseCase
  class CancelCertificate
    def initialize(eav_gateway)
      @assessment_attribute_gateway = eav_gateway
    end

    def execute(assessment_id)
      @assessment_attribute_gateway.update_assessment_attribute(assessment_id, "")
    end
  end
end
