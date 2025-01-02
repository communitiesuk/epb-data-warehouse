module Gateway
  class DomesticSearchGateway
    def fetch(date_start:, date_end:, row_limit: 5000, council: nil)
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
        ActiveRecord::Relation::QueryAttribute.new(
          "limit",
          row_limit,
          ActiveRecord::Type::Integer.new,
        ),
      ]

      sql = <<-SQL
        SELECT *
        FROM mvw_domestic_search#{' '}
        WHERE LODGEMENT_DATE BETWEEN $1 AND $2
      SQL

      unless council.nil?
        sql += " AND local_authority_label = $4"

        bindings << ActiveRecord::Relation::QueryAttribute.new(
          "council",
          council,
          ActiveRecord::Type::String.new,
        )
      end

      sql += " LIMIT $3"

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |result| result }
    end
  end
end
