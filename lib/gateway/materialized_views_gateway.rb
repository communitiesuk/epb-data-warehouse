module Gateway
  class MaterializedViewsGateway
    def fetch_all
      sql = <<-SQL
        select matviewname from pg_matviews
      SQL
      ActiveRecord::Base.connection.exec_query(sql).map { |result| result["matviewname"] }
    end

    def refresh(name:, concurrently: false)
      raise Boundary::InvalidArgument, name unless fetch_all.include? name

      str = concurrently ? "CONCURRENTLY" : ""
      sql = "REFRESH MATERIALIZED VIEW #{str} #{name}"
      begin
        ActiveRecord::Base.connection.exec_query(sql, "SQL")
      rescue StandardError => e
        pp e.message
      end
    end
  end
end
