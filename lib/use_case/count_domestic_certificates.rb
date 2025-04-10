module UseCase
  class CountDomesticCertificates
    def initialize(search_gateway:)
      @search_gateway = search_gateway
    end

    def execute(*args)
      this_args = args[0]
      @search_gateway.count(**this_args)
    end
  end
end
