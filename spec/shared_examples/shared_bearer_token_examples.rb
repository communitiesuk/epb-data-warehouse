# frozen_string_literal: true

shared_examples "when checking an endpoint requires bearer token access" do |end_point:|
  context "when making a request with no bearer token to #{end_point}" do
    let(:response) do
      get "/api/#{end_point}"
    end

    it "returns status 403" do
      expect(response.status).to eq(403)
    end

    it "raises an error due to the missing token" do
      expect(response.body).to include "You are not authenticated"
    end
  end

  context "when making a request with an invalid bearer token to #{end_point}" do
    before do
      authenticate_user_use_case = instance_double(UseCase::AuthenticateUser)
      allow(Container).to receive(:authenticate_user_use_case).and_return(authenticate_user_use_case)
      allow(authenticate_user_use_case).to receive(:execute).and_return(false)
    end

    let(:response) do
      header("Authorization", "Bearer invalid-bearer-token")
      get "/api/#{end_point}"
    end

    it "returns status 403" do
      expect(response.status).to eq(403)
    end

    it "raises an error due to the missing token" do
      expect(response.body).to include "You are not authenticated"
    end
  end
end
