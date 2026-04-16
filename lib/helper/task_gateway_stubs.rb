module Helper::TaskGatewayStubs
  class UserCredentialsGateway
    def initialize(users)
      @users = users.split(",").map(&:strip)
    end

    def get_opt_in_users
      @users
    end
  end

  class KmsGateway
    def decrypt(encrypted_email)
      encrypted_email
    end
  end
end
