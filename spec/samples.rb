class Samples
  def self.xml(schema, type = "epc")
    path = File.join Dir.pwd, "spec/fixtures/samples/#{schema}/#{type}.xml"

    unless File.exist? path
      raise ArgumentError,
            "No #{type} sample found for schema #{schema}, create one at #{
              path
            }"
    end

    File.read path
  end
end
