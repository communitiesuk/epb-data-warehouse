shared_context "when saving attributes" do
  def fetch_attribute_id_by_assessment(assessment_id:, attribute_name:)
    sql = <<-SQL
            SELECT aav.attribute_id#{' '}
            FROM assessment_attribute_values aav
            JOIN assessment_attributes av ON aav.attribute_id = av.attribute_id
           WHERE assessment_id = $1 and attribute_name = $2
    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "attribute_name",
        attribute_name,
        ActiveRecord::Type::String.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |row| row["attribute_id"] }
  end
end
