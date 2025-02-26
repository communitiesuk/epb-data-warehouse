module Gateway
  class CommercialSearchGateway
    def initialize; end

    def fetch(date_start, date_end, row_limit: nil)
      sql = <<-SQL
        SELECT * FROM mvw_commercial_search#{' '}
      SQL

      sql += "WHERE lodgement_date BETWEEN $1 AND $2"
      unless row_limit.nil?
        sql += " ORDER BY RRN"
        sql += " LIMIT $3"
      end
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "date_start",
          date_start,
          ActiveRecord::Type::Date.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "date_end",
          date_end,
          ActiveRecord::Type::Date.new,
        ),
      ]
      unless row_limit.nil?
        bindings << ActiveRecord::Relation::QueryAttribute.new(
          "row_limit",
          row_limit,
          ActiveRecord::Type::Integer.new,
        )
      end

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
    end
  end
end
