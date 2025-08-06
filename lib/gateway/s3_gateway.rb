require "aws-sdk-s3"

module Gateway
  class S3Gateway
    def initialize(s3_client: nil)
      @s3_client = s3_client || get_s3_client
      @signer_client = Aws::S3::Presigner.new(client: @s3_client)
    end

    def get_presigned_url(bucket:, file_name:, expires_in:)
      @s3_client.head_object(bucket:, key: file_name)
      @signer_client.presigned_url(:get_object, bucket:, key: file_name, expires_in:)
    rescue Aws::S3::Errors::NotFound
      raise Errors::FileNotFound, file_name
    end

  private

    def get_s3_client
      case ENV["APP_ENV"]
      when "production"
        Aws::S3::Client.new(region: "eu-west-2", credentials: Aws::ECSCredentials.new)
      else
        Aws::S3::Client.new(stub_responses: true)
      end
    end
  end
end
