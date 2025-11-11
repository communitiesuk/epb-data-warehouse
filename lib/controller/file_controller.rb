module Controller
  class FileController < BaseController
    get "/api/files/domestic/csv" do
      file_name = "full-load/domestic-csv.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/domestic/csv/info" do
      file_name = "full-load/domestic-csv.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/domestic/json" do
      file_name = "full-load/domestic-json.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/domestic/json/info" do
      file_name = "full-load/domestic-json.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/non-domestic/csv" do
      file_name = "full-load/non-domestic-csv.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/non-domestic/csv/info" do
      file_name = "full-load/non-domestic-csv.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/non-domestic/json" do
      file_name = "full-load/non-domestic-json.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/non-domestic/json/info" do
      file_name = "full-load/non-domestic-json.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/non-domestic-recommendations/json" do
      file_name = "full-load/non-domestic-recommendations-json.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/non-domestic-recommendations/json/info" do
      file_name = "full-load/non-domestic-recommendations-json.zip"
      get_s3_file_info(file_name)
    end

  private

    def redirect_to_s3_file(file_name)
      s3_url = Container.get_presigned_url_use_case.execute(file_name:)
      redirect s3_url
    rescue Errors::FileNotFound
      json_api_response code: 404, data: { error: "File not found" }
    rescue StandardError => e
      report_to_sentry(e)
      json_api_response code: 500, data: { error: "Internal Server Error" }
    end

    def get_s3_file_info(file_name)
      return_data = Container.get_file_info_use_case.execute(file_name:)
      json_api_response data: return_data
    rescue Errors::FileNotFound
      json_api_response code: 404, data: { error: "File not found" }
    rescue StandardError => e
      report_to_sentry(e)
      json_api_response code: 500, data: { error: "Internal Server Error" }
    end
  end
end
