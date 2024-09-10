module UseCase
  class RefreshAverageCo2Emissions
    def initialize(gateway:)
      @gateway = gateway
    end

    def execute(concurrently: false)
      @gateway.refresh(concurrently:)
    end
  end
end
