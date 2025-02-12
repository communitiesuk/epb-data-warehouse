module Gateway
  class DomesticSearchGateway
    attr_reader :columns

    def initialize
      @columns = fetch_columns
    end

    def fetch(*args)
      this_args = args.first
      sql = <<-SQL
        SELECT #{columns.join(', ')}
        FROM mvw_domestic_search#{' '}
      SQL

      this_args[:bindings] = get_bindings(**this_args)

      this_args[:sql] = sql
      sql = search_filter(**this_args)

      ActiveRecord::Base.connection.exec_query(sql, "SQL", this_args[:bindings]).map { |result| result }
    end

    def fetch_rr(*args)
      this_args = args.first
      sql = <<~SQL
         SELECT rr.rrn,
        improvement_item,
        improvement_id,
        indicative_cost,
        improvement_summary_text,
        improvement_descr_text
        FROM mvw_domestic_rr_search rr
        JOIN mvw_domestic_search m ON m.rrn=rr.rrn
      SQL

      this_args[:bindings] = get_bindings(**this_args)
      this_args[:sql] = sql
      sql = search_filter(**this_args)

      ActiveRecord::Base.connection.exec_query(sql, "SQL", this_args[:bindings]).map { |result| result }
    end

  private

    def search_filter(*args)
      this_args = args.first
      sql = this_args[:sql]
      sql += sql.include?("WHERE") ? " AND " : " WHERE "
      sql += "lodgement_date BETWEEN $1 AND $2"

      unless this_args[:council_id].nil?
        sql += " AND council_id = $3"
      end

      unless this_args[:row_limit].nil?
        sql += " ORDER BY RRN"
        sql += " LIMIT $#{this_args[:bindings].length}"
      end
      sql
    end

    def get_bindings(*args)
      this_args = args.first
      arr = [
        ActiveRecord::Relation::QueryAttribute.new(
          "date_start",
          this_args[:date_start],
          ActiveRecord::Type::Date.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "date_end",
          this_args[:date_end],
          ActiveRecord::Type::Date.new,
        ),
      ]
      unless this_args[:council_id].nil?
        arr << ActiveRecord::Relation::QueryAttribute.new(
          "council_id",
          this_args[:council_id],
          ActiveRecord::Type::Integer.new,
        )
      end

      unless this_args[:row_limit].nil?
        arr << ActiveRecord::Relation::QueryAttribute.new(
          "limit",
          this_args[:row_limit],
          ActiveRecord::Type::Integer.new,
        )

      end
      arr
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
