require "aws-sdk-dynamodb"

namespace :one_off do
  desc "Migrate user credentials from legacy table"
  task :migrate_user_credentials do
    client = Aws::DynamoDB::Client.new(region: "eu-west-2")
    dynamo_resource = Aws::DynamoDB::Resource.new(client: client)

    table_name_v1 = ENV.fetch("EPB_DATA_USER_CREDENTIAL_TABLE_NAME")
    table_name_v2 = ENV.fetch("EPB_DATA_USER_CREDENTIAL_V2_TABLE_NAME")

    table_v1 = dynamo_resource.table(table_name_v1)
    table_v2 = dynamo_resource.table(table_name_v2)

    scan_hash = {}
    onelogin_id = {}
    done = false
    start_key = nil
    until done
      scan_hash[:exclusive_start_key] = start_key unless start_key.nil?

      begin
        response = table_v1.scan(scan_hash)
      rescue Aws::DynamoDB::Errors::ProvisionedThroughputExceededException
        Kernel.sleep 2
        retry
      end
      response.items.each do |row|
        onelogin_id[row["OneLoginSub"]] ||= row["UserId"]
        profile_row = {
          "UserId" => onelogin_id[row["OneLoginSub"]],
          "Type" => "PROFILE",
          "GSI1_PK" => "ONELOGIN##{row['OneLoginSub']}",
          "Attributes" => {
            "CreatedAt" => row["CreatedAt"],
            "EmailAddress" => row["EmailAddress"],
            "OptOut" => row["OptOut"],
          },
        }
        bearer_row = {
          "UserId" => onelogin_id[row["OneLoginSub"]],
          "Type" => "TOKEN##{row['BearerToken']}",
          "GSI1_PK" => "TOKEN##{row['BearerToken']}",
          "Attributes" => {
            "CreatedAt" => row["CreatedAt"],
          },
        }

        [profile_row, bearer_row].each do |item|
          table_v2.put_item(
            item:,
            condition_expression: "attribute_not_exists(UserId)",
          )
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          next
        rescue Aws::DynamoDB::Errors::ProvisionedThroughputExceededException
          Kernel.sleep 2
          retry
        end
      end
      start_key = response.last_evaluated_key
      done = start_key.nil?

    end
  end
end
