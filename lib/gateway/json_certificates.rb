module Gateway
  class JsonCertificates
    # @deprecated
    # This is used only to seed dev data and is not a core part of the data warehouse.
    # It should be removed when the seed_test_data task is updated to use XML.
    attr_accessor :dir_path

    def initialize(path)
      @dir_path = "#{path}*.json"
    end

    def read
      Dir
        .glob(@dir_path)
    rescue StandardError
      raise Boundary::JsonDirectoryNotFound, @dir_path
    end
  end
end
