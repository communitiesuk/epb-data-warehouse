module UseCase
  class ImportEnums
    def initialize(assessment_lookups_gateway:, xsd_presenter:, assessment_attribute_gateway:)
      @assessment_lookups_gateway = assessment_lookups_gateway
      @assessment_attribute_gateway = assessment_attribute_gateway
      @xsd_presenter = xsd_presenter
    end

    def execute(enums_to_import)
      enums_to_import.each do |domain|
        attribute_id = @assessment_attribute_gateway.get_attribute_id(domain.attribute_name)
        enum_hashes = @xsd_presenter.get_enums_by_type(domain.xsd_node_name)
        enum_hashes.each do |schema_version, values|
          values.each do |key, value|
            @assessment_lookups_gateway.add_lookup(Domain::AssessmentLookup.new(
                                                     lookup_key: key,
                                                     lookup_value: value,
                                                     attribute_id: attribute_id,
                                                     type_of_assessment: domain.type_of_assessment,
                                                     schema_version: schema_version,
                                                   ))
          end
        end
      end
    end
  end
end
