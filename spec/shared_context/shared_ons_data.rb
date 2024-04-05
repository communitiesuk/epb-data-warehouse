shared_context "when saving ons data" do
  def import_postcode_directory_data
    file_path = File.join Dir.pwd, "spec/fixtures/ons_data/ons_postcode_directory.csv"
    sql = "TRUNCATE TABLE  ons_postcode_directory;
            COPY ons_postcode_directory(postcode,country_code,region_code,local_authority_code,westminster_parliamentary_constituency_code,other_areas)
            FROM '#{file_path}'
            DELIMITER ','
            CSV HEADER;"
    ActiveRecord::Base.connection.execute(sql)
  end

  def import_postcode_directory_name
    file_path = File.join Dir.pwd, "spec/fixtures/ons_data/ons_postcode_directory_names.csv"
    sql = "TRUNCATE TABLE  ons_postcode_directory_names; COPY ons_postcode_directory_names(area_code,name,type,type_code)
            FROM '#{file_path}'
            DELIMITER ','
            CSV HEADER;"
    ActiveRecord::Base.connection.execute(sql)
  end
end
