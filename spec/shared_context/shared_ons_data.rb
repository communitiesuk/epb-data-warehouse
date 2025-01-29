require "csv"

shared_context "when saving ons data" do
  def import_postcode_directory_data
    file_path = File.join Dir.pwd, "spec/fixtures/ons_data/ons_postcode_directory.csv"
    ActiveRecord::Base.connection.execute("TRUNCATE ons_postcode_directory")
    CSV.foreach(file_path, headers: true) do |row|
      sql = "INSERT INTO ons_postcode_directory(postcode,country_code,region_code,local_authority_code,westminster_parliamentary_constituency_code,other_areas)
            VALUES ('#{row['postcode']}','#{row['country_code']}','#{row['region_code']}', '#{row['local_authority_code']}', '#{row['westminster_parliamentary_constituency_code']}','#{row['other_areas']}' )"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def import_postcode_directory_name
    file_path = File.join Dir.pwd, "spec/fixtures/ons_data/ons_postcode_directory_names.csv"
    ActiveRecord::Base.connection.execute("TRUNCATE ons_postcode_directory_names RESTART IDENTITY CASCADE")
    CSV.foreach(file_path, headers: true) do |row|
      sql = "INSERT INTO ons_postcode_directory_names(area_code,name,type,type_code)
        VALUES ('#{row['area_code']}', '#{row['name']}', '#{row['type']}', '#{row['type_code']}')"
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
