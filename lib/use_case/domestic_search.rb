module UseCase
  class DomesticSearch
    def initialize(search_gateway:, ons_gateway:)
      @search_gateway = search_gateway
      @ons_gateway = ons_gateway
    end

    def execute(date_start:, date_end:, row_limit: nil, council: nil)
      raise Boundary::InvalidDates if date_start > date_end

      council_id = @ons_gateway.fetch_council_id(council) unless council.nil?

      @search_gateway.fetch(date_start:, date_end:, row_limit: row_limit, council_id: council_id)
    end
  end
end
