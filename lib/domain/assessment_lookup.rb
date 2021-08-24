module Domain
  class AssessmentLookup
    attr_reader :lookup_key, :lookup_value, :attribute_id, :schema, :schema_version
    attr_accessor :id

    def initialize(lookup_key:, lookup_value:, attribute_id:, schema:, schema_version: nil, id: 0)
      @id = id
      @lookup_key = lookup_key
      @lookup_value = lookup_value
      @attribute_id = attribute_id
      @schema = schema
      @schema_version = schema_version
    end

    def ==(other)
      @id == other.id &&
        @lookup_key == other.lookup_key &&
        @lookup_value == other.lookup_value &&
        @attribute_id == other.attribute_id &&
        @schema == other.schema &&
        @schema_version == other.schema_version
    end
  end
end
