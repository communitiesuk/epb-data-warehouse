module UseCase
  class FetchAverageCo2Emissions
    def initialize(gateway:)
      @gateway = gateway
    end

    def execute
      @gateway.fetch
    end
  end
end
