module UseCase
  class GetHeatPumpCountsByFloorArea
    def initialize(export_gateway:)
      @export_gateway = export_gateway
    end

    def execute(start_date:, end_date:)
      raw_data = @export_gateway.fetch_by_floor_area(start_date:, end_date:)
      result = {}
      raw_data.each do |key|
        result.merge!({ key["total_floor_area"] => key["number_of_assessments"] })
      end
      Domain::HeatPumpCountByFloorArea.new(result).to_hash
    end
  end
end
