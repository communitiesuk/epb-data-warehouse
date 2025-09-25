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
        timestamp || Time.now,
        ActiveRecord::Type::DateTime.new,
      ),
    ]
    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
  end

  def fetch_logs(date_start:, date_end:)
    sql = <<-SQL
          SELECT assessment_id as certificate_number,
                 CASE#{'  '}
                   WHEN event_type = 'cancelled' THEN 'removed'
                   WHEN event_type = 'opt_out'   THEN 'removed'
                   WHEN event_type = 'address_id_updated' THEN 'uprn_updated'
                 END as event_type,
                 timestamp
          FROM audit_logs
          WHERE timestamp BETWEEN $1 AND $2
            AND event_type != 'opt_in'
          ORDER BY timestamp
    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "date_start",
        date_start,
        ActiveRecord::Type::DateTime.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "date_end",
        date_end,
        ActiveRecord::Type::DateTime.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
  end
end
