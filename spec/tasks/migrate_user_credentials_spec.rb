require "spec_helper"
require "rake"
require "aws-sdk-dynamodb"

describe "one_off:migrate_user_credentials" do
  subject(:task) { get_task("one_off:migrate_user_credentials") }

  let(:dynamo_db_client) do
    Aws::DynamoDB::Client.new(
      stub_responses: true,
    )
  end

  let(:user_id) { "e40c46c3-4636-4a8a-abd7-be72e1a525f6" }
  let(:sub_id) { "mock-sub-id" }
  let(:email) { "test@email.com" }
  let(:bearer) { "abcdefghijklmnopqrstuv" }
  let(:created_at) { "2025-06-25 12:32:00 UTC" }
  let(:table_name) { "test_users_table" }
  let(:table_name_v2) { "test_users_table_v2" }

  let(:legacy_item) do
    {
      "UserId" => user_id,
      "OneLoginSub" => sub_id,
      "BearerToken" => bearer,
      "CreatedAt" => created_at,
      "EmailAddress" => email,
      "OptOut" => false,
    }
  end

  before do
    ENV["EPB_DATA_USER_CREDENTIAL_TABLE_NAME"] = table_name
    ENV["EPB_DATA_USER_CREDENTIAL_V2_TABLE_NAME"] = table_name_v2

    allow(Aws::DynamoDB::Client).to receive(:new).and_return(dynamo_db_client)
  end

  describe "migrating items" do
    context "when a legacy record is successfully scanned" do
      before do
        dynamo_db_client.stub_responses(:scan, {
          items: [legacy_item],
          last_evaluated_key: nil,
        })
        allow(Kernel).to receive(:sleep)
      end

      it "inserts the user profile and token rows into the v2 table" do
        task.invoke

        api_requests = dynamo_db_client.api_requests

        scan_request = api_requests.find { |req| req[:operation_name] == :scan }
        expect(scan_request[:params][:table_name]).to eq(table_name)

        put_requests = api_requests.select { |req| req[:operation_name] == :put_item }
        expect(put_requests.count).to eq(2)

        expect(put_requests[0][:params][:table_name]).to eq(table_name_v2)
        expect(put_requests[0][:params][:condition_expression]).to eq("attribute_not_exists(UserId)")
        expect(put_requests[0][:params][:item]).to eq({
          "UserId" => { s: user_id },
          "Type" => { s: "PROFILE" },
          "GSI1_PK" => { s: "ONELOGIN##{sub_id}" },
          "Attributes" => { m: {
            "CreatedAt" => { s: created_at },
            "EmailAddress" => { s: email },
            "OptOut" => { bool: false },
          } },
        })

        expect(put_requests[1][:params][:table_name]).to eq(table_name_v2)
        expect(put_requests[1][:params][:condition_expression]).to eq("attribute_not_exists(UserId)")
        expect(put_requests[1][:params][:item]).to eq({
          "UserId" => { s: user_id },
          "Type" => { s: "TOKEN##{bearer}" },
          "GSI1_PK" => { s: "TOKEN##{bearer}" },
          "Attributes" => { m: {
            "CreatedAt" => { s: created_at },
          } },
        })
      end
    end

    context "when the scan returns duplicated users" do
      before do
        dynamo_db_client.stub_responses(:scan, {
          items: %w[user1 user2 user3].map { |id| legacy_item.merge({ "UserId" => id }) },
          last_evaluated_key: nil,
        })
      end

      it "consolidates into three puts with same user id" do
        task.invoke

        api_requests = dynamo_db_client.api_requests
        put_requests = api_requests.select { |req| req[:operation_name] == :put_item }
        expect(put_requests.count).to eq(6)
        put_requests.each do |req|
          expect(req[:params][:item]["UserId"][:s]).to eq "user1"
        end
      end
    end

    context "when the scan returns paginated results (last_evaluated_key)" do
      before do
        dynamo_db_client.stub_responses(:scan, [
          {
            items: [legacy_item],
            last_evaluated_key: { "UserId" => user_id },
          },
          {
            items: [legacy_item],
            last_evaluated_key: nil,
          },
        ])
      end

      it "continues to scan using the exclusive_start_key until done" do
        task.invoke

        scan_requests = dynamo_db_client.api_requests.select { |req| req[:operation_name] == :scan }
        expect(scan_requests.count).to eq(2)

        expect(scan_requests[0][:params][:exclusive_start_key]).to be_nil

        expect(scan_requests[1][:params][:exclusive_start_key]).to eq({ "UserId" => { s: user_id } })

        put_requests = dynamo_db_client.api_requests.select { |req| req[:operation_name] == :put_item }
        expect(put_requests.count).to eq(4)
      end
    end
  end

  describe "error handling" do
    before do
      dynamo_db_client.stub_responses(:scan, {
        items: [legacy_item],
        last_evaluated_key: nil,
      })
    end

    context "when a record already exists in the v2 table (ConditionalCheckFailedException)" do
      before do
        dynamo_db_client.stub_responses(:put_item, "ConditionalCheckFailedException")
      end

      it "rescues the exception and skips without failing" do
        expect { task.invoke }.not_to raise_error
      end
    end

    context "when writing to the new table gets throttled (ProvisionedThroughputExceededException)" do
      before do
        dynamo_db_client.stub_responses(:put_item, [
          "ProvisionedThroughputExceededException",
          {},
          {},
        ])
      end

      it "sleeps for 2 seconds and retries the item" do
        expect(Kernel).to receive(:sleep).with(2)

        task.invoke

        put_requests = dynamo_db_client.api_requests.select { |req| req[:operation_name] == :put_item }
        expect(put_requests.count).to eq(3)
      end
    end

    context "when scanning the legacy table gets throttled" do
      before do
        dynamo_db_client.stub_responses(:scan, [
          "ProvisionedThroughputExceededException",
          {
            items: [legacy_item],
            last_evaluated_key: nil,
          },
        ])
      end

      it "sleeps for 2 seconds and retries the scan" do
        expect(Kernel).to receive(:sleep).with(2)

        task.invoke

        scan_requests = dynamo_db_client.api_requests.select { |req| req[:operation_name] == :scan }
        expect(scan_requests.count).to eq(2)
      end
    end
  end
end
