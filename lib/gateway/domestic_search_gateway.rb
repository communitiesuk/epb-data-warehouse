module Gateway
  class DomesticSearchGateway
    attr_reader :columns

    def initialize
      @columns = fetch_columns
    end

    def fetch(date_start:, date_end:, row_limit: nil, council_id: nil)
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "date_start",
          date_start,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "date_end",
          date_end,
          ActiveRecord::Type::String.new,
        ),
      ]

      sql = <<-SQL
        SELECT #{columns.join(', ')}
        FROM mvw_domestic_search#{' '}
        WHERE LODGEMENT_DATE BETWEEN $1 AND $2
      SQL

      unless council_id.nil?
        sql += " AND council_id = $3"

        bindings << ActiveRecord::Relation::QueryAttribute.new(
          "council_id",
          council_id,
          ActiveRecord::Type::Integer.new,
        )
      end

      sql += " ORDER BY RRN"

      unless row_limit.nil?
        sql += " LIMIT $#{bindings.length + 1}"
        bindings << ActiveRecord::Relation::QueryAttribute.new(
          "limit",
          row_limit,
          ActiveRecord::Type::Integer.new,
        )

      end

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |result| result }
    end

    def fetch_columns
      sql = <<-SQL
        SELECT a.attname
        FROM pg_attribute a
          JOIN pg_class t on a.attrelid = t.oid
        WHERE a.attnum > 0
          AND NOT a.attisdropped
          AND t.relname = 'mvw_domestic_search'
          AND a.attname NOT IN ('council_id')
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL").map { |result| result["attname"] }
    end
  end
end
