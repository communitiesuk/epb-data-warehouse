module UseCase
  class DomesticSearch
    def initialize(search_gateway:, ons_gateway:)
      @search_gateway = search_gateway
      @ons_gateway = ons_gateway
    end

    def execute(*args)
      this_args = args[0]
      raise Boundary::InvalidDates if this_args[:date_start] > this_args[:date_end]

      results = {}
      results[:domestic] = @search_gateway.fetch(**this_args)

      results
    end
  end
end
