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
end
