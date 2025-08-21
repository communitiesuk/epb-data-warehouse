module UseCase
  class AuthenticateUser
    def initialize(user_credentials_gateway:)
      @user_credentials_gateway = user_credentials_gateway
    end

    def execute(bearer_token)
      @user_credentials_gateway.bearer_token_exists?(bearer_token)
    end
  end
end
