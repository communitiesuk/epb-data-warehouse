require "aws-sdk-s3"

module Gateway
  class StorageGateway
    attr_reader :client

    def initialize(bucket_name:, stub_responses: false)
      @bucket_name = bucket_name
      @client = stub_responses ? initialise_client_stub : initialise_client
    end

    def write_file(file_name:, data:)
      client.put_object(
        body: data,
        bucket: @bucket_name,
        key: file_name,
      )
    rescue Aws::S3::Errors::ServiceError
      raise
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
