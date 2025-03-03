module UseCase
  class FixAttributeDuplicates
    def initialize(assessment_attribute_gateway:)
      @assessment_attribute_gateway = assessment_attribute_gateway
    end

    def execute
      duplicate_attributes = @assessment_attribute_gateway.fetch_duplicate_attributes
      raise Boundary::NoData, "No dupes found" if duplicate_attributes.empty?

      @assessment_attribute_gateway.fix_duplicate_attributes(duplicate_attributes:)
      duplicate_attributes.length
    end
  end
end
