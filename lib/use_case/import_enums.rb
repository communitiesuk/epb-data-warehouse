module UseCase
  class ImportEnums
    def initialize(assessment_lookups_gateway:, xsd_presenter:, assessment_attribute_gateway:)
      @assessment_lookups_gateway = assessment_lookups_gateway
      @assessment_attribute_gateway = assessment_attribute_gateway
      @xsd_presenter = xsd_presenter
    end

    def execute(attribute_mappings)
      attribute_mappings.each do |attribute|
        enum_hashes = @xsd_presenter.get_enums_by_type(attribute["xsd_node_name"])

        if @xsd_presenter.variation_between_schema_versions?(enum_hashes)
          enum_hashes.each do |schema_version, values|
            save_lookup(values: values, attribute: attribute, schema_version: schema_version)
          end
        else
          save_lookup(values: enum_hashes.first[1], attribute: attribute)
        end
      end
    end

    private

    def save_lookup(values:, attribute:, schema_version: nil)
      attribute_id = attribute_id(attribute)

      values.each do |key, value|
        @assessment_lookups_gateway.add_lookup(Domain::AssessmentLookup.new(
                                                 lookup_key: key,
                                                 lookup_value: value,
                                                 attribute_id: attribute_id,
                                                 type_of_assessment: attribute["type_of_assessment"] || nil,
                                                 schema_version: schema_version,
                                               ))
      end
    end

    def attribute_id(attribute)
      @assessment_attribute_gateway.get_attribute_id(attribute["attribute_name"])
    end
  end
end
