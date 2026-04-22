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
      params = {
        filter_expression: "BearerToken = :bearer_token",
        expression_attribute_values: { ":bearer_token" => bearer_token },
      }

      scan_all_pages(params) do |items|
        return true if items.any?
      end

      false
    end

    def get_opt_in_users
      emails = []
      params = {
        filter_expression: "OptOut = :o",
        expression_attribute_values: {
          ":o" => false,
        },
      }

      scan_all_pages(params) do |items|
        items.each do |item|
          emails << item["EmailAddress"] unless item["EmailAddress"].nil?
        end
      end

      emails
    end

  private

    def scan_all_pages(params)
      loop do
        resp = @table.scan(params)
        yield resp.items
        break unless resp.last_evaluated_key

        params[:exclusive_start_key] = resp.last_evaluated_key
      end
    end

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
