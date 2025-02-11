require "csv"
require "date"

module UseCase
  class ExportUserData
    def initialize(domestic_search_gateway:, multipart_storage_gateway:, ons_gateway:)
      @domestic_search_gateway = domestic_search_gateway
      @multipart_storage_gateway = multipart_storage_gateway
      @ons_gateway = ons_gateway
    end

    def execute(date_start:, date_end:, council: nil)
      council_id = @ons_gateway.fetch_council_id(council) unless council.nil?

      date_start_dt = Date.parse(date_start)
      date_end_dt = Date.parse(date_end)

      start_year = date_start_dt.year
      end_year = date_end_dt.year

      council = "All-Councils" if council.nil?
      s3_file_name = "#{date_start}_#{date_end}_#{council.tr(' ', '-')}.csv"

      upload_id = nil

      years_range = (start_year..end_year).to_a
      part_number = 1
      parts_uploaded = []
      upload_buffer = ""

      begin
        years_range.each do |year|
          check_size = year != years_range.last

          if years_range.length == 1 # The range only covers one year
            current_date_start = date_start
            current_date_end = date_end
          elsif year == years_range.first # The range is multi-year (initial year case)
            current_date_start = date_start
            current_date_end = "#{year}-12-31"
          elsif year == years_range.last # The range is multi-year (final year case)
            current_date_start = "#{year}-01-01"
            current_date_end = date_end
          else # The range is multi-year (years in the middle)
            current_date_start = "#{year}-01-01"
            current_date_end = "#{year}-12-31"
          end

          search_result = @domestic_search_gateway.fetch(date_start: current_date_start, date_end: current_date_end, council_id:)
          next unless search_result.any?

          csv_result = convert_to_csv(data: search_result)
          upload_buffer << csv_result

          next unless !check_size || @multipart_storage_gateway.buffer_size_check?(size: upload_buffer.size)

          upload_id = @multipart_storage_gateway.create_upload(file_name: s3_file_name) if upload_id.nil?
          parts_uploaded << @multipart_storage_gateway.upload_part(file_name: s3_file_name, upload_id: upload_id, part_number: part_number, data: upload_buffer.dup)
          part_number += 1
          upload_buffer.clear
        end

        raise Boundary::NoData, "Domestic Search query" if upload_id.nil?

        @multipart_storage_gateway.complete_upload(file_name: s3_file_name, upload_id: upload_id, parts: parts_uploaded)
      rescue Errors::MultipartUploadError
        @multipart_storage_gateway.abort_upload(file_name: s3_file_name, upload_id: upload_id)
        raise
      end
    end

  private

    def convert_to_csv(data:)
      CSV.generate(headers: true) do |csv|
        csv << data.first.keys # Add column names
        data.each { |hash| csv << hash.values }
      end
    end
  end
end
