module UseCase
  class GetHeatPumpCountsByFloorArea
    def initialize(export_gateway:)
      @export_gateway = export_gateway
    end

    def execute(start_date:, end_date:)
      @export_gateway.fetch_by_floor_area(start_date:, end_date:)
    end
  end
end
