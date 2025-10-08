module Domain
  class LookupValues
    def initialize(data:)
      @data = data.map { |i| i.transform_keys(&:to_sym) }
    end

    def get_results
      @data.map { |i| i[:key] }.uniq.map { |i| { key: i, values: get_values(i) } }
    end

  private

    def get_values(key)
      keys_to_extract = %i[value schema_version]
      @data.select { |row| row[:key] == key }.map { |i| i.select { |key, _| keys_to_extract.include? key } }
    end
  end
end
