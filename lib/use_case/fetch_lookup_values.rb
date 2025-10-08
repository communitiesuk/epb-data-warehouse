module UseCase
  class FetchLookupValues
    def initialize(gateway:)
      @gateway = gateway
    end

    def execute(name:, schema_version: nil, lookup_key: nil)
      result = @gateway.fetch_lookups_values(name: name, schema_version:, lookup_key:)

      raise Boundary::NoData, "lookup values" if result.empty?

      Domain::LookupValues.new(data: result).get_results
    end
  end
end
