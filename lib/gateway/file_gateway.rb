require "csv"

module Gateway
  class FileGateway
    def save_csv(data, file_name)
      csv_data = CSV.generate(
        write_headers: true,
        headers: data.first.keys,
      ) { |csv| data.each { |row| csv << row } }
      File.write(file_name, csv_data)
      csv_data
    end
  end
end
