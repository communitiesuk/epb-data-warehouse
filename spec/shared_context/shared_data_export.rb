require "csv"

shared_context "when exporting data" do
  def read_csv_fixture(file_name, parse: true)
    file_path = File.join Dir.pwd, "spec/fixtures/export_csv/#{file_name}.csv"
    read_file = File.read(file_path)

    CSV.parse(read_file, headers: true) if parse
  end

  def refresh_mview(name:)
    retries = 2
    try = 0
    begin
      Gateway::MaterializedViewsGateway.new.refresh(name:)
    rescue StandardError
      try += 1
      sleep(2)
      retry if try < retries
    end
  end
end
