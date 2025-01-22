shared_context "when exporting data" do
  def read_csv_fixture(file_name, parse: true)
    file_path = File.join Dir.pwd, "spec/fixtures/export_csv/#{file_name}.csv"
    read_file = File.read(file_path)
    CSV.parse(read_file, headers: true) if parse
  end
end
