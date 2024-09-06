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
  end
end