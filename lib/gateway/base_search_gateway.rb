module Gateway
  class BaseSearchGateway
    attr_reader :columns, :mvw_name

    def initialize
      @columns = fetch_columns
    end

    def fetch(*args)
      this_args = args.first
      sql = <<-SQL
        SELECT #{columns.join(', ')}
        FROM #{mvw_name}
      SQL

      this_args[:bindings] = get_bindings(**this_args)

      this_args[:sql] = sql
      sql = search_filter(**this_args)

      ActiveRecord::Base.connection.exec_query(sql, "SQL", this_args[:bindings]).map { |result| result }
    end

    def count(*args)
      this_args = args.first
      sql = <<~SQL
        SELECT COUNT(*)
        FROM #{mvw_name}
      SQL

      this_args[:bindings] = get_bindings(**this_args)

      this_args[:sql] = sql
      sql = search_filter(**this_args)

      ActiveRecord::Base.connection.exec_query(sql, "SQL", this_args[:bindings]).first["count"]
    end

  private

    def fetch_columns
      sql = <<-SQL
        SELECT a.attname
        FROM pg_attribute a
          JOIN pg_class t on a.attrelid = t.oid
        WHERE a.attnum > 0
          AND NOT a.attisdropped
          AND t.relname = '#{mvw_name}'
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL").map { |result| result["attname"] }
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
      unless this_args[:council].nil?
        this_args[:council].each_with_index do |council, idx|
          arr << ActiveRecord::Relation::QueryAttribute.new(
            "council_#{idx + 1}",
            council,
            ActiveRecord::Type::String.new,
          )
        end
      end

      unless this_args[:constituency].nil?
        this_args[:constituency].each_with_index do |constituency, idx|
          arr << ActiveRecord::Relation::QueryAttribute.new(
            "constituency_#{idx + 1}",
            constituency,
            ActiveRecord::Type::String.new,
          )
        end
      end

      unless this_args[:postcode].nil?
        arr << ActiveRecord::Relation::QueryAttribute.new(
          "postcode",
          this_args[:postcode],
          ActiveRecord::Type::String.new,
        )
      end

      unless this_args[:eff_rating].nil?
        this_args[:eff_rating].each_with_index do |rating, idx|
          arr << ActiveRecord::Relation::QueryAttribute.new(
            "eff_rating_#{idx + 1}",
            rating,
            ActiveRecord::Type::String.new,
          )
        end
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

    def search_filter(*args)
      this_args = args.first
      sql = this_args[:sql]
      sql << (sql.include?("WHERE") ? " AND " : " WHERE ")
      sql << "lodgement_date BETWEEN $1 AND $2"

      index = 3
      unless this_args[:council].nil?
        sql << " AND local_authority_label IN ("
        sql << this_args[:council].each_with_index.map { |_, idx| "$#{index + idx}" }.join(", ")
        sql << ")"
        index += this_args[:council].size
      end

      unless this_args[:constituency].nil?
        sql << " AND constituency_label IN ("
        sql << this_args[:constituency].each_with_index.map { |_, idx| "$#{index + idx}" }.join(", ")
        sql << ")"
        index += this_args[:constituency].size
      end

      unless this_args[:postcode].nil?
        sql << " AND postcode = $#{index}"
        index += 1
      end

      unless this_args[:eff_rating].nil?
        sql << " AND current_energy_rating IN ("
        sql << this_args[:eff_rating].each_with_index.map { |_, idx| "$#{index + idx}" }.join(", ")
        sql << ")"
        index += this_args[:eff_rating].size
      end

      unless this_args[:row_limit].nil?
        sql << " ORDER BY RRN"
        sql << " LIMIT $#{index}"
      end
      sql
    end
  end
end
