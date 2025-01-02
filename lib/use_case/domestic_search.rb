module UseCase
  class DomesticSearch
    def initialize(gateway:)
      @gateway = gateway
    end

    def execute(date_start:, date_end:, row_limit: nil, council: nil)
      raise Boundary::InvalidDates if date_start > date_end

      @gateway.fetch(date_start:, date_end:, row_limit: row_limit, council: council)
    end
  end
end
