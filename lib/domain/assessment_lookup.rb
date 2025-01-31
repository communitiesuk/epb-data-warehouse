module Domain
  class AssessmentLookup
    attr_reader :lookup_key, :lookup_value, :attribute_id, :type_of_assessment, :schema_version
    attr_accessor :id

    def initialize(lookup_key:, lookup_value:, attribute_id:, type_of_assessment:, attribute_name:, schema_version: nil, id: 0)
      @id = id
      @lookup_key = lookup_key
      @attribute_id = attribute_id
      @type_of_assessment = type_of_assessment
      @schema_version = schema_version
      @attribute_name = attribute_name
      set_lookup_value(lookup_value)
    end

    def set_lookup_value(lookup_value)
      if @attribute_name == "construction_age_band"
        match = lookup_value.match(/^England and Wales:.*?(?=;)/)
        @lookup_value = match ? match[0] : lookup_value
      else
        @lookup_value = lookup_value
      end
    end

    def ==(other)
      @lookup_key == other.lookup_key &&
        @lookup_value == other.lookup_value &&
        @attribute_id == other.attribute_id &&
        @type_of_assessment == other.type_of_assessment &&
        @schema_version == other.schema_version
    end
  end
end
