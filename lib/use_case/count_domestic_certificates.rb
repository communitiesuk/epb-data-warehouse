module UseCase
  class CountDomesticCertificates
    def initialize(search_gateway:, ons_gateway:)
      @search_gateway = search_gateway
      @ons_gateway = ons_gateway
    end

    def execute(*args)
      this_args = args[0]
      this_args[:council_id] = @ons_gateway.fetch_council_id(this_args[:council]) unless this_args[:council].nil?
      @search_gateway.count(**this_args)
    end
  end
end
