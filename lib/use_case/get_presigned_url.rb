require "aws-sdk-s3"

module UseCase
  class GetPresignedUrl
    def initialize(gateway:, bucket_name:)
      @gateway = gateway
      @bucket_name = bucket_name
    end

    def execute(file_name:, expires_in: 30)
      @gateway.get_presigned_url(bucket: @bucket_name, file_name:, expires_in:)
    rescue Aws::S3::Errors::NoSuchKey
      raise Errors::FileNotFound
    end
  end
end
