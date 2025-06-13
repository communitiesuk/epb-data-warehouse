require "csv"

shared_context "when exporting data" do
  def read_csv_fixture(file_name, parse: true)
    file_path = File.join Dir.pwd, "spec/fixtures/export_csv/#{file_name}.csv"
    read_file = File.read(file_path)

    CSV.parse(read_file, headers: true) if parse
  end

  def get_columns_from_view(view_name)
    sql = <<-SQL
        SELECT a.attname
        FROM pg_attribute a
          JOIN pg_class t on a.attrelid = t.oid
        WHERE a.attnum > 0
          AND NOT a.attisdropped
          AND t.relname = '#{view_name}'
    SQL

    ActiveRecord::Base.connection.exec_query(sql, "SQL").map { |result| result["attname"] }
  end

  def retry_mview(name:, max_attempts: 5)
    attempts = 0
    begin
      attempts += 1
      yield
    rescue StandardError => e
      if attempts < max_attempts
        sleep(1) # Optional: Add delay between retries
        Gateway::MaterializedViewsGateway.new.refresh(name:)
        retry
      else
        raise "Operation failed after #{max_attempts} attempts. Last error: #{e.message}"
      end
    end
  end
end
