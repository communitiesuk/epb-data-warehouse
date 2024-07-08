describe Gateway::StorageGateway do
  context "when storage is initialised" do
    subject(:storage_gateway) do
      described_class.new(
        bucket_name: "my-bucket",
        stub_responses: true,
      )
    end

    let(:fake_s3) { {} }

    before do
      stub_file_response(storage_gateway.client)
      storage_gateway.client.create_bucket(bucket: "my-bucket")
    end

    it "can write an object" do
      response = storage_gateway.write_file(file_name: "test", data: "Hello!")
      expect(response.successful?).to be(true)
    end
  end
end

def stub_file_response(client)
  client.stub_responses(
    :create_bucket, lambda { |context|
                      name = context.params[:bucket]
                      if fake_s3[name]
                        "BucketAlreadyExists"
                      else
                        fake_s3[name] = {}
                        {}
                      end
                    }
  )
  client.stub_responses(
    :put_object, lambda { |context|
                   bucket = context.params[:bucket]
                   key = context.params[:key]
                   body = context.params[:body]
                   bucket_contents = fake_s3[bucket]
                   if bucket_contents
                     bucket_contents[key] = body
                     {}
                   else
                     "NoSuchBucket"
                   end
                 }
  )
end
