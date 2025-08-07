require "aws-sdk-s3"

module UseCase
  class GetFileInfo
    def initialize(gateway:, bucket_name:)
      @gateway = gateway
      @bucket_name = bucket_name
    end

    def execute(file_name:)
      @gateway.get_file_info(bucket: @bucket_name, file_name:)
    rescue Aws::S3::Errors::NoSuchKey
      raise Errors::FileNotFound
    end
  end
end
