require "aws-sdk-dynamodb"

module Gateway
  class UserCredentialsGateway
    def initialize(dynamo_db_client: nil)
      table_name = ENV["EPB_DATA_USER_CREDENTIAL_TABLE_NAME"]
      client = dynamo_db_client || get_dynamo_db_client
      @dynamo_resource = Aws::DynamoDB::Resource.new(client: client)
      @table = @dynamo_resource.table(table_name)
    end

    def bearer_token_exists?(bearer_token)
      resp = @table.scan(
        filter_expression: "BearerToken = :bearer_token",
        expression_attribute_values: {
          ":bearer_token" => bearer_token,
        },
      )
      !resp.count.zero?
    end

    def get_opt_in_users
      users = @table.scan(
        filter_expression: "OptOut = :o",
        expression_attribute_values: {
          ":o" => false,
        },
      )
      emails = []
      users.items.each do |item|
        emails << item["EmailAddress"] unless item["EmailAddress"].nil?
      end
      emails
    end

  private

    def get_dynamo_db_client
      case ENV["APP_ENV"]
      when "local", nil
        Aws::DynamoDB::Client.new(stub_responses: true)
      else
        Aws::DynamoDB::Client.new(region: "eu-west-2")
      end
    end
  end
end
