module Gateway
  class DomesticSearchGateway
    def fetch(date_start:, date_end:, row_limit: nil, council: nil)
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
        SELECT *
        FROM mvw_domestic_search#{' '}
        WHERE LODGEMENT_DATE BETWEEN $1 AND $2
      SQL

      unless council.nil?
        sql += " AND local_authority_label = $3"

        bindings << ActiveRecord::Relation::QueryAttribute.new(
          "council",
          council,
          ActiveRecord::Type::String.new,
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
  end
end
