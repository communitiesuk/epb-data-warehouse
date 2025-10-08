class Gateway::CommercialReportsGateway
  def insert_report(assessment_id:, related_rrn:)
    sql = <<-SQL
            INSERT INTO commercial_reports(assessment_id, related_rrn)
            VALUES($1, $2)
            ON CONFLICT (assessment_id) DO UPDATE SET related_rrn= $2;

    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "related_rrn",
        related_rrn,
        ActiveRecord::Type::String.new,
      ),
    ]
    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
  end
end
