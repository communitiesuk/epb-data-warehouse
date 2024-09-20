module Gateway
  class AverageCo2EmissionsGateway
    def fetch
      this_month = Date.today.strftime("%Y-%m")
      sql = <<-SQL
        SELECT ROUND((avg_co2_emission)::numeric)::integer as avg_co2_emission,
               country,
               year_month,
              assessment_type
        FROM mvw_avg_co2_emissions
        WHERE year_month not like ('#{this_month}');
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL").map { |result| result }
    end

    def fetch_all
      this_month = Date.today.strftime("%Y-%m")

      sql = <<-SQL
        SELECT ROUND((SUM(avg_co2_emission * cnt) / SUM(cnt))::numeric)::integer AS avg_co2_emission,
               year_month,
              assessment_type
        FROM mvw_avg_co2_emissions
        WHERE year_month not like ('#{this_month}')
        GROUP BY year_month, assessment_type ;
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
