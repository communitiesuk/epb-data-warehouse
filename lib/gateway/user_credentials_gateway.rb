require "aws-sdk-dynamodb"

module Gateway
  class UserCredentialsGateway
    def initialize(dynamo_db_client: nil)
      table_name = ENV["EPB_DATA_USER_CREDENTIAL_TABLE_NAME"]
      client = dynamo_db_client || get_dynamo_db_client
      @dynamo_resource = Aws::DynamoDB::Resource.new(client: client)
      @table = @dynamo_resource.table(table_name)
    end

    def bearer_token_exist?(bearer_token)
      resp = @table.scan(
        filter_expression: "BearerToken = :bearer_token",
        expression_attribute_values: {
          ":bearer_token" => bearer_token,
        },
      )
      !resp.count.zero?
    end

  private

    def get_dynamo_db_client
      Aws::DynamoDB::Client.new(region: "eu-west-2", credentials: Aws::ECSCredentials.new)
    end
  end
end
