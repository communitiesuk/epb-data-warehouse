module Domain
  class HeatPumpCountByFloorArea
    def initialize(data)
      @data = data
    end

    def to_hash
      {
        between_0_and_50: @data["BETWEEN 0 AND 50"].nil? ? 0 : @data["BETWEEN 0 AND 50"],
        between_101_and_150: @data["BETWEEN 101 AND 150"].nil? ? 0 : @data["BETWEEN 101 AND 150"],
        between_151_200: @data["BETWEEN 151 AND 200"].nil? ? 0 : @data["BETWEEN 151 AND 200"],
        between_201_250: @data["BETWEEN 201 AND 250"].nil? ? 0 : @data["BETWEEN 201 AND 250"],
        between_51_100: @data["BETWEEN 51 AND 100"].nil? ? 0 : @data["BETWEEN 51 AND 100"],
        greater_than_251: @data["GREATER THAN 251"].nil? ? 0 : @data["GREATER THAN 251"],
      }
    end
  end
end
