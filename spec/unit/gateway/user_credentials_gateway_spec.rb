require "aws-sdk-dynamodb"

describe Gateway::UserCredentialsGateway do
  subject(:gateway) { described_class.new(dynamo_db_client:) }

  let(:dynamo_db_client) do
    Aws::DynamoDB::Client.new(
      stub_responses: true,
    )
  end

  let(:token) do
    "4AzwlHwpNp46ydvLN31bSVpCN3CQbvee050P7aERWXFbgzFJckPfZXqFmcR0GFxT"
  end

  describe "#bearer_token_exists" do
    context "when checking for an existing token" do
      before do
        dynamo_db_client.stub_responses(:query, {
          items: [
            {
              "UserId" => "user_id",
              "GSI1_PK" => "TOKEN##{token}",
            },
          ],
          count: 1,
        })
      end

      it "returns true" do
        expect(gateway.bearer_token_exists?(token)).to be(true)

        query_request = dynamo_db_client.api_requests.find { |req| req[:operation_name] == :query }
        expect(query_request[:params][:key_condition_expression]).to eq("GSI1_PK = :token")
        expect(query_request[:params][:expression_attribute_values]).to eq({ ":token" => { s: "TOKEN##{token}" } })
      end
    end

    context "when checking for a none existent token" do
      before do
        dynamo_db_client.stub_responses(:query, {
          items: [],
          count: 0,
        })
      end

      it "returns false" do
        expect(gateway.bearer_token_exists?("missing-sub-id")).to be(false)
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

    before do
      dynamo_db_client.stub_responses(:scan, {
        items: [
          {
            "UserId" => "user_id",
            "Type" => "PROFILE",
            "Attributes" => {
              "CreatedAt" => "created_at",
              "EmailAddress" => "encrypted_email_1",
              "OptOut" => false,
            },
            "GSI1_PK" => "ONELOGIN#sub_id_1",
          },
          {
            "UserId" => "user_id_2",
            "Type" => "PROFILE",
            "Attributes" => {
              "CreatedAt" => "created_at",
              "EmailAddress" => "encrypted_email_2",
              "OptOut" => false,
            },
            "GSI1_PK" => "ONELOGIN#sub_id_2",
          },
        ],
        count: 2,
      })
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
        dynamo_db_client.stub_responses(:scan, {
          items: [
            {
              "UserId" => "user_id",
              "Type" => "PROFILE",
              "Attributes" => {
                "CreatedAt" => "created_at",
                "EmailAddress" => "encrypted_email_1",
                "OptOut" => false,
              },
              "GSI1_PK" => "ONELOGIN#sub_id_1",
            },
            {
              "UserId" => "user_id_2",
              "Type" => "PROFILE",
              "Attributes" => {
                "CreatedAt" => "created_at",
                "EmailAddress" => "encrypted_email_2",
                "OptOut" => false,
              },
              "GSI1_PK" => "ONELOGIN#sub_id_2",
            },
            {
              "UserId" => "user_id_3",
              "Type" => "PROFILE",
              "Attributes" => {
                "CreatedAt" => "created_at",
                "OptOut" => false,
              },
              "GSI1_PK" => "ONELOGIN#sub_id_3",
            },
          ],
          count: 2,
        })
      end

      it "returns the emails" do
        expect(gateway.get_opt_in_users).to eq %w[encrypted_email_1 encrypted_email_2]
      end
    end

    context "when email results are paginated" do
      let(:last_evaluated_key) do
        { "UserId" => "user_id_1" }
      end

      before do
        dynamo_db_client.stub_responses(
          :scan,
          {
            items: [
              {
                "UserId" => "user_id_1",
                "Type" => "PROFILE",
                "Attributes" => {
                  "CreatedAt" => "created_at",
                  "EmailAddress" => "encrypted_email_1",
                  "OptOut" => false,
                },
                "GSI1_PK" => "ONELOGIN#sub_id_1",
              },
            ],
            count: 1,
            last_evaluated_key: last_evaluated_key,
          },
          {
            items: [
              {
                "UserId" => "user_id_2",
                "Type" => "PROFILE",
                "Attributes" => {
                  "CreatedAt" => "created_at",
                  "EmailAddress" => "encrypted_email_2",
                  "OptOut" => false,
                },
                "GSI1_PK" => "ONELOGIN#sub_id_2",
              },
            ],
            count: 1,
          },
        )
      end

      it "returns emails from all pages and forwards exclusive_start_key on subsequent scans" do
        expect(gateway.get_opt_in_users).to eq %w[encrypted_email_1 encrypted_email_2]

        scan_requests = dynamo_db_client.api_requests.select { |req| req[:operation_name] == :scan }

        expect(scan_requests.count).to eq(2)
        expect(scan_requests[0][:params][:exclusive_start_key]).to be_nil
        expect(scan_requests[1][:params][:exclusive_start_key]).to eq({ "UserId" => { s: "user_id_1" } })
      end
    end
  end
end
