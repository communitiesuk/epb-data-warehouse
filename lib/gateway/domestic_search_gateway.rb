module Gateway
  class DomesticSearchGateway
    def fetch
      sql = <<-SQL
        SELECT *
        FROM mvw_domestic_search
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL").map { |result| result }
    end
  end
end
