module UseCase
  class FetchLookups
    def initialize(gateway:)
      @gateway = gateway
    end

    def execute
      @gateway.fetch_lookups
    end
  end
end
