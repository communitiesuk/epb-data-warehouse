module Gateway
  class CommercialSearchGateway < Gateway::BaseSearchGateway
    def initialize
      @mvw_name = "mvw_commercial_search"
      super
    end
  end
end
