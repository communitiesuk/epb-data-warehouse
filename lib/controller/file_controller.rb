module Controller
  class FileController < BaseController
    get "/api/files/:property_type", auth_token_has_all: %w[epb-data-front:read] do
      file_name = "#{params[:property_type]}/full-load/#{params[:property_type]}.zip"
      s3_url = Container.get_presigned_url_use_case.execute(file_name:)
      redirect s3_url
    rescue Errors::FileNotFound
      json_api_response code: 404, data: { error: "File not found" }
    rescue StandardError => e
      report_to_sentry(e)
      json_api_response code: 500, data: { error: "Internal Server Error" }
    end

    get "/api/files/:property_type/info", auth_token_has_all: %w[epb-data-front:read] do
      file_name = "#{params[:property_type]}/full-load/#{params[:property_type]}.zip"
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
