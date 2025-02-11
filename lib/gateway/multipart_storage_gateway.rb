require "aws-sdk-s3"

module Gateway
  class MultipartStorageGateway
    attr_reader :client

    MINIMUM_UPLOAD_SIZE = 5 * 1024 * 1024

    def initialize(bucket_name:, stub_responses: false)
      @bucket_name = bucket_name
      @client = stub_responses ? initialise_client_stub : initialise_client
    end

    def create_upload(file_name:)
      @client.create_multipart_upload(
        {
          bucket: @bucket_name,
          key: file_name,
        },
      ).upload_id
    rescue Aws::S3::Errors::ServiceError
      raise
    end

    def upload_part(file_name:, upload_id:, part_number:, data:)
      part = @client.upload_part(
        bucket: @bucket_name,
        key: file_name,
        upload_id: upload_id,
        part_number: part_number,
        body: data,
      )
      { etag: part.etag, part_number: part_number }
    rescue Aws::S3::Errors::ServiceError
      raise
    end

    def complete_upload(file_name:, upload_id:, parts:)
      @client.complete_multipart_upload(
        bucket: @bucket_name,
        key: file_name,
        upload_id: upload_id,
        multipart_upload: { parts: parts },
      )
    rescue Aws::S3::Errors::ServiceError
      raise
    end

    def buffer_size_check?(size:)
      size >= MINIMUM_UPLOAD_SIZE
    end

  private

    def initialise_client
      Aws::S3::Client.new(
        region: "eu-west-2",
        credentials: Aws::ECSCredentials.new,
      )
    end

    def initialise_client_stub
      Aws::S3::Client.new(stub_responses: true)
    end
  end
end
