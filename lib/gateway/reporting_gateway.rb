module Gateway
  class ReportingGateway
    def heat_pump_count_for_sap
      last_month = Date.today.strftime("%Y-%m-01").to_date - 1.days
      start_date = last_month.to_date.prev_year + 1.days
      end_date = last_month.to_date

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "start_date",
          start_date,
          ActiveRecord::Type::DateTime.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "end_date",
          end_date,
          ActiveRecord::Type::DateTime.new,
        ),
      ]

      sql = <<-SQL
       SELECT COUNT(*) as num_epcs, to_char(nullif(document->>'registration_date', '')::date, 'MM-YYYY') as month_year
        FROM assessment_documents ad
        WHERE  (document->>'registration_date')::date BETWEEN $1 AND $2
        AND ad.document ->> 'assessment_type' = 'SAP'
        AND ad.document -> 'main_heating' ->0 ->> 'description' LIKE '%heat pump%'
        GROUP BY to_char(nullif(document->>'registration_date', '')::date, 'MM-YYYY')
      SQL

      results = ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)

      results.map { |result| result }
    end
  end
end
