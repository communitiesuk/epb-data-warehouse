module Gateway
  class JsonCertificates
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
