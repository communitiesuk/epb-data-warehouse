describe Gateway::MultipartStorageGateway do
  context "when storage is initialised" do
    subject(:storage_gateway) do
      described_class.new(
        bucket_name: "my-bucket",
        stub_responses: true,
      )
    end

    let(:fake_s3) { {} }
    let(:fake_multipart_s3) { [] }

    context "when doing multipart uploads" do
      before do
        stub_file_response(storage_gateway.client)
        storage_gateway.client.create_bucket(bucket: "my-bucket")
      end

      it "catches and raises an error if upload_id was not created" do
        expect { storage_gateway.upload_part(file_name: "test", upload_id: "fake_id", part_number: 1, data: "Hello!") }.to raise_error Aws::S3::Errors::NoSuchUpload
      end

      it "successfully upload parts" do
        upload_id = storage_gateway.create_upload(file_name: "test")
        response = storage_gateway.upload_part(file_name: "test", upload_id: upload_id, part_number: 1, data: "Hello!")
        expect(response[:etag]).not_to be_nil
      end

      it "successfully completes upload parts" do
        upload_id = storage_gateway.create_upload(file_name: "test")
        parts = []
        parts << storage_gateway.upload_part(file_name: "test", upload_id: upload_id, part_number: 1, data: "Hello!")
        parts << storage_gateway.upload_part(file_name: "test", upload_id: upload_id, part_number: 2, data: "Hello!")
        expect { storage_gateway.complete_upload(file_name: "test", upload_id: upload_id, parts: parts) }.not_to raise_error
      end
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
    :create_multipart_upload, lambda { |context|
                                bucket = context.params[:bucket]
                                key = context.params[:key]
                                upload_id = rand(9999).to_s
                                fake_multipart_s3 << upload_id
                                {
                                  bucket: bucket,
                                  key: key,
                                  upload_id: upload_id,
                                }
                              }
  )

  client.stub_responses(
    :upload_part, lambda { |context|
                    context.params[:bucket]
                    context.params[:key]
                    upload_id = context.params[:upload_id]
                    context.params[:part_number]
                    context.params[:data]
                    if fake_multipart_s3.include?(upload_id)
                      {
                        etag: "\"d8c2eafd90c266e19ab9dcacc479f8af\"",
                      }
                    else
                      "NoSuchUpload"
                    end
                  }
  )

  client.stub_responses(
    :complete_multipart_upload, lambda { |context|
                                  bucket = context.params[:bucket]
                                  key = context.params[:key]
                                  upload_id = context.params[:upload_id]
                                  if fake_multipart_s3.include?(upload_id)
                                    {
                                      bucket: bucket,
                                      etag: "\"4d9031c7644d8081c2829f4ea23c55f7-2\"",
                                      key: key,
                                      location: "https://#{bucket}.s3.eu-west-2.amazonaws.com/#{key}",
                                    }
                                  else
                                    "NoSuchUpload"
                                  end
                                }
  )
end
