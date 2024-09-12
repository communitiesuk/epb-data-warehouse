module UseCase
  class FetchAverageCo2Emissions
    def initialize(gateway:)
      @gateway = gateway
    end

    def execute
      return_hash = { all: @gateway.fetch_all }

      country_stats = @gateway.fetch

      group_by_country = country_stats.group_by { |stat| stat["country"] }.transform_values(&:flatten)
      group_by_country.each_with_object({}) do |(country, stats), _h|
        return_hash[key_name(country:)] = stats
      end
      return_hash
    end

  private

    def key_name(country:)
      country.downcase.parameterize(separator: "_").to_sym
    end
  end
end
