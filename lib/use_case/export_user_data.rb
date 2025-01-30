require "csv"

module UseCase
  class ExportUserData
    def initialize(domestic_search_gateway:, storage_gateway:)
      @domestic_search_gateway = domestic_search_gateway
      @storage_gateway = storage_gateway
    end

    def execute(date_start:, date_end:, council:)
      search_result = @domestic_search_gateway.fetch(date_start:, date_end:, council:)
      csv_result = convert_to_csv(data: search_result)
      s3_file_name = "#{date_start}_#{date_end}_#{council.tr(' ', '-')}.csv"
      @storage_gateway.write_file(file_name: s3_file_name, data: csv_result)
    end

    def convert_to_csv(data:)
      csv_string = CSV.generate(headers: true) do |csv|
        csv << data.first.keys # Add column names
        data.each { |hash| csv << hash.values }
      end
      csv_string.force_encoding("UTF-8")
    end
  end
end
