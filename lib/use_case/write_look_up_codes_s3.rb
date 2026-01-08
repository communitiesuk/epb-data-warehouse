module UseCase
  class WriteLookUpCodesS3
    def initialize(s3_gateway:, look_up_gateway:)
      @s3_gateway = s3_gateway
      @look_up_gateway = look_up_gateway
    end

    def execute(bucket:, file_name:)
      data = @look_up_gateway.fetch_look_up_csv_data
      @s3_gateway.write_csv_file(bucket:, file_name:, data: data)
    end
  end
end
