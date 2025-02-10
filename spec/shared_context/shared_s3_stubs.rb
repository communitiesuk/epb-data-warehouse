shared_context "when stubbing multipart uploads to S3" do
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
end
