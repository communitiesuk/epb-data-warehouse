require "aws-sdk-dynamodb"

module Gateway
  class UserCredentialsGateway
    def initialize(dynamo_db_client: nil)
      table_name = ENV.fetch("EPB_DATA_USER_CREDENTIAL_V2_TABLE_NAME")
      client = dynamo_db_client || get_dynamo_db_client
      @dynamo_resource = Aws::DynamoDB::Resource.new(client: client)
      @table = @dynamo_resource.table(table_name)
    end

    def bearer_token_exists?(bearer_token)
      params = {
        index_name: "GSI1_PK_Index",
        key_condition_expression: "GSI1_PK = :token",
        expression_attribute_values: { ":token" => "TOKEN##{bearer_token}" },
      }
      response = @table.query(
        **params,
      )
      response.items.any?
    end

    def get_opt_in_users
      emails = []
      params = {
        projection_expression: "Attributes.EmailAddress",
        filter_expression: "Attributes.OptOut = :o",
        expression_attribute_values: {
          ":o" => false,
        },
      }

      scan_all_pages(params) do |items|
        items.each do |item|
          email = item.dig("Attributes", "EmailAddress")
          emails << email if email
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
      if ENV["APP_ENV"] == "production"
        Aws::DynamoDB::Client.new(region: "eu-west-2")
      elsif ENV.fetch("APP_ENV", "development") == "development" && ENV["AWS_ENDPOINT_URL_DYNAMODB"]
        Aws::DynamoDB::Client.new(
          endpoint: ENV["AWS_ENDPOINT_URL_DYNAMODB"],
          region: "eu-west-2",
          credentials: Aws::Credentials.new(
            ENV["AWS_ACCESS_KEY_ID"],
            ENV["AWS_SECRET_ACCESS_KEY"],
          ),
        )
      else
        Aws::DynamoDB::Client.new(stub_responses: true)
      end
    end
  end
end
