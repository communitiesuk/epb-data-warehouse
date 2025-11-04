shared_context "when saving enum data to lookup tables" do
  def fetch_saved_data(attribute_name:)
    sql = <<-SQL
            SELECT lookup_value, lookup_key, schema_version
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        INNER JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = '#{attribute_name}'
        ORDER BY schema_version
    SQL

    ActiveRecord::Base.connection.exec_query(sql).map { |rows| rows }
  end

  def fetch_saved_data_by_schema_version(attribute_name:, schema_version:)
    sql = <<-SQL
            SELECT lookup_value, lookup_key
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        INNER JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = '#{attribute_name}'
        AND schema_version = '#{schema_version}'
        ORDER BY lookup_key
    SQL

    ActiveRecord::Base.connection.exec_query(sql).map { |rows| rows }
  end

  def fetch_schemas(attribute_name:)
    sql = <<-SQL
            SELECT DISTINCT schema_version
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        INNER JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = '#{attribute_name}'
    SQL

    ActiveRecord::Base.connection.exec_query(sql).map { |rows| rows["schema_version"] }
  end

  def fetch_counts(attribute_name:)
    sql = <<-SQL
        SELECT COUNT(DISTINCT lookup_key) cnt, schema_version
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        INNER JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = '#{attribute_name}'
        GROUP BY schema_version
    SQL

    ActiveRecord::Base.connection.exec_query(sql).map { |rows| rows }
  end

  def import_attributes
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_attributes CASCADE;")
    ActiveRecord::Base.connection.reset_pk_sequence!("assessment_attributes")
    assessment_lookups_gateway = Gateway::AssessmentAttributesGateway.new
    file_path = File.join Dir.pwd, "spec/fixtures/lookup_data/assessment_attributes.csv"
    CSV.foreach(file_path, headers: true) do |row|
      assessment_lookups_gateway.add_attribute(attribute_name: row["attribute_name"])
    end
  end

  def import_look_ups(schema_versions:)
    attributes = ActiveRecord::Base.connection.exec_query("SELECT * FROM assessment_attributes").map { |row| row }
    gateway = Gateway::AssessmentLookupsGateway.new
    gateway.truncate_tables
    file_path = File.join Dir.pwd, "spec/fixtures/look_up_data.csv"
    CSV.foreach(file_path, headers: true) do |i|
      row = i.to_hash
      next unless schema_versions.include? row["schema_version"]

      data = attributes.find { |a| a["attribute_name"] == row["attribute_name"] }

      attribute_id = data.nil? ? Gateway::AssessmentAttributesGateway.new.add_attribute(attribute_name: row["attribute_name"]) : data["attribute_id"]
      gateway.add_lookup(Domain::AssessmentLookup.new(
                           attribute_name: row["attribute_name"],
                           lookup_key: row["lookup_key"],
                           lookup_value: row["lookup_value"],
                           attribute_id:,
                           type_of_assessment: row["type_of_assessment"],
                           schema_version: row["schema_version"],
                         ))
    end
  end
end
