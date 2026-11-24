module Controller
  class FileController < BaseController
    get "/api/files/domestic/csv", has_bearer_token: true do
      file_name = "full-load/domestic-csv.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/domestic/csv/info", has_bearer_token: true do
      file_name = "full-load/domestic-csv.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/domestic/json", has_bearer_token: true do
      file_name = "full-load/domestic-json.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/domestic/json/info", has_bearer_token: true do
      file_name = "full-load/domestic-json.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/non-domestic/csv", has_bearer_token: true do
      file_name = "full-load/non-domestic-csv.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/non-domestic/csv/info", has_bearer_token: true do
      file_name = "full-load/non-domestic-csv.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/non-domestic/json", has_bearer_token: true do
      file_name = "full-load/non-domestic-json.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/non-domestic/json/info", has_bearer_token: true do
      file_name = "full-load/non-domestic-json.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/non-domestic-recommendations/json", has_bearer_token: true do
      file_name = "full-load/non-domestic-recommendations-json.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/non-domestic-recommendations/json/info", has_bearer_token: true do
      file_name = "full-load/non-domestic-recommendations-json.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/display/csv", has_bearer_token: true do
      file_name = "full-load/display-csv.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/display/csv/info", has_bearer_token: true do
      file_name = "full-load/display-csv.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/display/json", has_bearer_token: true do
      file_name = "full-load/display-json.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/display/json/info", has_bearer_token: true do
      file_name = "full-load/display-json.zip"
      get_s3_file_info(file_name)
    end

    get "/api/files/display-recommendations/json", has_bearer_token: true do
      file_name = "full-load/display-recommendations-json.zip"
      redirect_to_s3_file(file_name)
    end

    get "/api/files/display-recommendations/json/info", has_bearer_token: true do
      file_name = "full-load/display-recommendations-json.zip"
      get_s3_file_info(file_name)
    end

  private

    def redirect_to_s3_file(file_name)
      s3_url = Container.get_presigned_url_use_case.execute(file_name:)
      redirect s3_url
    rescue Errors::FileNotFound
      json_api_response code: 404, data: { error: "File not found" }
    end

    def get_s3_file_info(file_name)
      return_data = Container.get_file_info_use_case.execute(file_name:)
      json_api_response data: return_data
    rescue Errors::FileNotFound
      json_api_response code: 404, data: { error: "File not found" }
    end
  end
end
