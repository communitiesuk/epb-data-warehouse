require "aws-sdk-dynamodb"

describe Gateway::UserCredentialsGateway do
  subject(:gateway) { described_class.new(dynamo_db_client:) }

  let(:dynamo_db_client) do
    Aws::DynamoDB::Client.new(
      region: "eu-west-2",
      credentials: Aws::Credentials.new("fake_access_key_id", "fake_secret_access_key"),
    )
  end

  let(:token) do
    "4AzwlHwpNp46ydvLN31bSVpCN3CQbvee050P7aERWXFbgzFJckPfZXqFmcR0GFxT"
  end

  before do
    WebMock.enable!
  end

  describe "#bearer_token_exists?" do
    context "when the token exists" do
      let(:expected_query_body) do
        {
          "FilterExpression":
            "BearerToken = :bearer_token",
          "ExpressionAttributeValues": {
            ":bearer_token": { "S": token },
          },
          "TableName": "test_users_table",
        }.to_json
      end

      let(:query_response) do
        {
          "Items" => [
            {
              "UserId" => { "S" => "user_id" },
              "OneLoginSub" => { "S" => "mock-sub-id" },
              "CreatedAt" => { "S" => Time.now.to_s },
              "BearerToken" => { "S" => token },
            },
          ],
          "Count" => 1,
        }.to_json
      end

      before do
        WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com")
               .with(body: expected_query_body,
                     headers: {
                       "X-Amz-Target" => "DynamoDB_20120810.Scan",
                     })
               .to_return(status: 200, body: query_response)
      end

      it "returns true" do
        expect(gateway.bearer_token_exists?(token)).to be(true)
      end
    end

    context "when the token does not exist" do
      let(:expected_query_body) do
        {
          "FilterExpression":
            "BearerToken = :bearer_token",
          "ExpressionAttributeValues": {
            ":bearer_token": { "S": "invalid-token" },
          },
          "TableName": "test_users_table",
        }.to_json
      end

      let(:query_response) do
        {
          "Items" => [],
          "Count" => 0,
        }.to_json
      end

      before do
        WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com")
               .with(body: expected_query_body,
                     headers: {
                       "X-Amz-Target" => "DynamoDB_20120810.Scan",
                     })
               .to_return(status: 200, body: query_response)
      end

      it "returns false" do
        expect(gateway.bearer_token_exists?("invalid-token")).to be(false)
      end
    end

    context "when the token exists in the second page of results" do
      let(:first_page_response) do
        {
          "Items" => [],
          "Count" => 0,
          "LastEvaluatedKey" => { "UserId" => { "S" => "last_user_id" } },
        }.to_json
      end

      let(:second_page_response) do
        {
          "Items" => [
            {
              "UserId" => { "S" => "user_id" },
              "OneLoginSub" => { "S" => "mock-sub-id" },
              "CreatedAt" => { "S" => Time.now.to_s },
              "BearerToken" => { "S" => token },
            },
          ],
          "Count" => 1,
        }.to_json
      end

      let(:expected_query_body) do
        {
          "FilterExpression":
            "BearerToken = :bearer_token",
          "ExpressionAttributeValues": {
            ":bearer_token": { "S": token },
          },
          "TableName": "test_users_table",
        }.to_json
      end

      let(:second_page_query_body) do
        {
          "FilterExpression": "BearerToken = :bearer_token",
          "ExpressionAttributeValues": { ":bearer_token": { "S": token } },
          "ExclusiveStartKey": { "UserId": { "S": "last_user_id" } },
          "TableName": "test_users_table",
        }.to_json
      end

      before do
        WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com/")
               .with(body: expected_query_body,
                     headers: { "X-Amz-Target" => "DynamoDB_20120810.Scan" })
               .to_return(status: 200, body: first_page_response)

        WebMock.stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com/")
               .with(body: second_page_query_body,
                     headers: { "X-Amz-Target" => "DynamoDB_20120810.Scan" })
               .to_return(status: 200, body: second_page_response)
      end

      it "returns true" do
        expect(gateway.bearer_token_exists?(token)).to be(true)
      end
    end
  end

  describe "#get_opt_in_users" do
    let(:user_id) do
      "e40c46c3-4636-4a8a-abd7-be72e1a525f6"
    end

    let(:sub_id) do
      "mock-sub-id"
    end

    let(:query_response) do
      {
        "Items" => [
          {
            "UserId" => { "S" => user_id },
            "OneLoginSub" => { "S" => sub_id },
            "CreatedAt" => { "S" => Time.now.to_s },
            "EmailAddress" => { "S" => "encrypted_email_1" },
            "OptOut" => { "BOOL" => false },
            "BearerToken" => { "S" => "the-bearer-token" },
          },
          {
            "UserId" => { "S" => user_id },
            "OneLoginSub" => { "S" => sub_id },
            "CreatedAt" => { "S" => Time.now.to_s },
            "EmailAddress" => { "S" => "encrypted_email_2" },
            "OptOut" => { "BOOL" => false },
            "BearerToken" => { "S" => "the-bearer-token" },
          },
        ],
        "Count" => 2,
      }.to_json
    end

    before do
      stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com/")
        .with(
          headers: {
            "Host" => "dynamodb.eu-west-2.amazonaws.com",
            "X-Amz-Target" => "DynamoDB_20120810.Scan",
          },
        )
        .to_return(status: 200, body: query_response, headers: {})
    end

    it "returns data for user who have not opted out" do
      expect(gateway.get_opt_in_users).to eq %w[encrypted_email_1 encrypted_email_2]
    end

    context "when an email missing from the items" do
      let(:query_response) do
        {
          "Items" => [
            {
              "UserId" => { "S" => user_id },
              "OneLoginSub" => { "S" => sub_id },
              "CreatedAt" => { "S" => Time.now.to_s },
              "EmailAddress" => { "S" => "encrypted_email_1" },
              "OptOut" => { "BOOL" => false },
              "BearerToken" => { "S" => "the-bearer-token" },
            },
            {
              "UserId" => { "S" => user_id },
              "OneLoginSub" => { "S" => sub_id },
              "CreatedAt" => { "S" => Time.now.to_s },
              "OptOut" => { "BOOL" => false },
              "BearerToken" => { "S" => "the-bearer-token" },
            },
            {
              "UserId" => { "S" => user_id },
              "OneLoginSub" => { "S" => sub_id },
              "CreatedAt" => { "S" => Time.now.to_s },
              "EmailAddress" => { "S" => "encrypted_email_2" },
              "OptOut" => { "BOOL" => false },
              "BearerToken" => { "S" => "the-bearer-token" },
            },
          ],
          "Count" => 3,
        }.to_json
      end

      before do
        stub_request(:post, "https://dynamodb.eu-west-2.amazonaws.com/")
          .with(
            headers: {
              "Host" => "dynamodb.eu-west-2.amazonaws.com",
              "X-Amz-Target" => "DynamoDB_20120810.Scan",
            },
          )
          .to_return(status: 200, body: query_response, headers: {})
      end

      it "returns the emails" do
        expect(gateway.get_opt_in_users).to eq %w[encrypted_email_1 encrypted_email_2]
      end
    end
  end
end
