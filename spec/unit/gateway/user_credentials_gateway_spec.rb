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
        expect(gateway.bearer_token_exist?(token)).to be(true)
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
        expect(gateway.bearer_token_exist?("invalid-token")).to be(false)
      end
    end
  end
end
