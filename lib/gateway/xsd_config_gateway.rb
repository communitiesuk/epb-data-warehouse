module Gateway
  class XsdConfigGateway
    attr_accessor :config

    def initialize(path)
      @config = JSON.parse(File.read(path))
    end

    def nodes
      @config["nodes"]
    end

    def paths
      @config["paths"]
    end

    def nodes_and_paths
      nodes_hash = nodes
      nodes_hash.each do |attribute|
        if !attribute.key?("xsd_path")
          attribute["xsd_path"] = paths[attribute["type_of_assessment"].downcase]
        end
        nodes_hash
      end
    end
  end
end
