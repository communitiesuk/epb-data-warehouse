module Gateway
  class AverageCo2EmissionsGateway
    def fetch
      sql = <<-SQL
        SELECT avg_co2_emission,
               country,
               year_month
        FROM mvw_avg_co2_emissions;
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL").map { |result| result }
    end

    def refresh(concurrently: false)
      str = concurrently ? "CONCURRENTLY" : ""
      sql = "REFRESH MATERIALIZED VIEW #{str} mvw_avg_co2_emissions"
      ActiveRecord::Base.connection.exec_query(sql, "SQL")
    end
  end
end
