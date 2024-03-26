require "csv"

module Gateway
  class FileGateway
    attr_reader :file_name

    def initialize(file_name)
      @file_name = file_name
    end

    def save_csv(data)
      csv_data = CSV.generate(
        write_headers: true,
        headers: data.first.keys,
      ) { |csv| data.each { |row| csv << row } }
      File.write(@file_name, csv_data)
      csv_data
    end
  end
end
