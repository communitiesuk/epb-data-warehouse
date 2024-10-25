module UseCase
  class RefreshMaterializedView
    def initialize(gateway:)
      @gateway = gateway
    end

    def execute(name:, concurrently: false)
      @gateway.refresh(name:, concurrently:)
    rescue Boundary::InvalidArgument => e
      raise e
    end
  end
end
