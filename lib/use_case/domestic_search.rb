module UseCase
  class DomesticSearch
    def initialize(search_gateway:, ons_gateway:)
      @search_gateway = search_gateway
      @ons_gateway = ons_gateway
    end

    def execute(*args)
      this_args = args[0]
      raise Boundary::InvalidDates if this_args[:date_start] > this_args[:date_end]

      this_args[:council_id] = @ons_gateway.fetch_council_id(this_args[:council]) unless this_args[:council].nil?
      results = {}
      results[:domestic] = @search_gateway.fetch(**this_args)
      results[:domestic_rr] = @search_gateway.fetch_rr(**this_args) unless this_args[:recommendations].nil?
      results
    end
  end
end
