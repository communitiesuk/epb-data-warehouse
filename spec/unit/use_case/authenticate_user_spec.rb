describe UseCase::AuthenticateUser do
  subject(:use_case) do
    described_class.new(user_credentials_gateway:)
  end

  let(:user_credentials_gateway) do
    instance_double(Gateway::UserCredentialsGateway)
  end

  context "when the user token exists" do
    let(:valid_token) do
      "existing-token"
    end

    before do
      allow(user_credentials_gateway).to receive(:bearer_token_exists?).with(valid_token).and_return(true)
    end

    it "returns true" do
      expect(use_case.execute(valid_token)).to be true
    end
  end

  context "when the user token does not exist" do
    let(:invalid_token) do
      "non-existing-token"
    end

    before do
      allow(user_credentials_gateway).to receive(:bearer_token_exists?).with(invalid_token).and_return(false)
    end

    it "returns false" do
      expect(use_case.execute(invalid_token)).to be false
    end
  end
end
