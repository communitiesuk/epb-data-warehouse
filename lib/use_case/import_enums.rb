module UseCase
  class ImportEnums
    def initialize(assessment_lookups_gateway:, xsd_presenter:, assessment_attribute_gateway:, xsd_config_gateway:)
      @assessment_lookups_gateway = assessment_lookups_gateway
      @assessment_attribute_gateway = assessment_attribute_gateway
      @xsd_presenter = xsd_presenter
      @xsd_config_gateway = xsd_config_gateway
    end

    def execute
      @assessment_lookups_gateway.truncate_tables
      @xsd_config_gateway.nodes_and_paths.each do |attribute|
        begin
          enum_hashes = @xsd_presenter.get_enums_by_type(ViewModelDomain::XsdArguments.new(simple_type: attribute["xsd_node_name"],
                                                                                           assessment_type: attribute["type_of_assessment"],
                                                                                           xsd_dir_path: attribute["xsd_path"],
                                                                                           node_hash: attribute["node_hash"]))
        rescue StandardError => e
          raise Boundary::EnumImportError.new(attribute["xsd_node_name"], e.message)
        end

        enum_hashes.each do |schema_version, values|
          save_lookup(values:, attribute:, schema_version:)
        end
      end
    end

  private

    def save_lookup(values:, attribute:, schema_version: nil)
      attribute_id = @assessment_attribute_gateway.add_attribute(attribute_name: attribute["attribute_name"])

      values.each do |key, value|
        @assessment_lookups_gateway.add_lookup(Domain::AssessmentLookup.new(
                                                 lookup_key: key.to_s,
                                                 lookup_value: value.to_s,
                                                 attribute_id:,
                                                 type_of_assessment: attribute["type_of_assessment"] || nil,
                                                 schema_version: schema_version.nil? ? nil : schema_version.gsub("/SAP", ""),
                                                 attribute_name: attribute["attribute_name"],
                                               ))
      end
    end
  end
end
