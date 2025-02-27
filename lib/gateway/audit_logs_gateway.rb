class Gateway::AuditLogsGateway
  def initialize; end

  def insert_log(assessment_id:, event_type:, timestamp:)
    sql = <<-SQL
          INSERT INTO audit_logs(assessment_id, event_type, timestamp)
          VALUES($1, $2, $3)
          ON CONFLICT (assessment_id, event_type)#{' '}
          DO UPDATE SET timestamp=$3
    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "event_type",
        event_type,
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "timestamp",
        timestamp,
        ActiveRecord::Type::DateTime.new,
      ),
    ]
    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
  end
end
