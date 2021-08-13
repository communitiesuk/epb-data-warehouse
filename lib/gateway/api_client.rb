module Gateway
  class ApiClient
    def initialize
      @client = Auth::HttpClient.new ENV["EPB_AUTH_CLIENT_ID"],
                                     ENV["EPB_AUTH_CLIENT_SECRET"],
                                     ENV["EPB_AUTH_SERVER"],
                                     ENV["EPB_API_URL"],
                                     OAuth2::Client
    end

    def self.delegate(*methods)
      methods.each do |method_name|
        define_method(method_name) do |*args, &block|
          @client.request(method_name, *args, &block)
        end
      end
    end

    delegate :get, :post, :put
  end
end
