module Domain
  class EnumArguments
    attr_reader :attribute_name, :xsd_node_name, :type_of_assessment

    def initialize(attribute_name:, xsd_node_name:, type_of_assessment:)
      @attribute_name = attribute_name
      @xsd_node_name = xsd_node_name
      @type_of_assessment = type_of_assessment
    end
  end
end
