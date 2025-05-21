require "csv"

shared_context "when exporting data" do
  def read_csv_fixture(file_name, parse: true)
    file_path = File.join Dir.pwd, "spec/fixtures/export_csv/#{file_name}.csv"
    read_file = File.read(file_path)

    CSV.parse(read_file, headers: true) if parse
  end

  def retry_operation(max_attempts: 5)
    attempts = 0
    begin
      attempts += 1
      yield
    rescue StandardError
      if attempts < max_attempts
        sleep(1) # Optional: Add delay between retries
        retry
      else
        raise "Operation failed after #{max_attempts} attempts. Last error: #{e.message}"
      end
    end
  end
end
