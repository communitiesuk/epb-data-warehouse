shared_context "when fetching recommendations report" do
  def get_bindings(*args)
    this_args = args.first
    arr = []

    unless this_args[:eff_rating].nil?
      this_args[:eff_rating].each_with_index do |rating, idx|
        arr << ActiveRecord::Relation::QueryAttribute.new(
          "eff_rating_#{idx + 1}",
          rating,
          ActiveRecord::Type::String.new,
        )
      end
    end

    arr.concat [
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

    index = 1

    unless this_args[:eff_rating].nil?
      sql << " JOIN ( VALUES "
      sql << this_args[:eff_rating].each_with_index.map { |_, idx| "($#{index + idx})" }.join(", ")
      sql << ") vals (v) "
      sql << "ON (current_energy_rating = v)"
      index += this_args[:eff_rating].size
    end

    sql << (sql.include?("WHERE") ? " AND " : " WHERE ")
    sql << "lodgement_date BETWEEN $#{index} AND $#{index + 1}"
    index += 2

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

    unless this_args[:row_limit].nil?
      sql << " ORDER BY certificate_number"
      sql << " LIMIT $#{index}"
    end
    sql
  end

  def fetch_rr
    sql = <<~SQL
       SELECT rr.certificate_number,
      improvement_item,
      improvement_id,
      indicative_cost,
      improvement_summary_text,
      improvement_descr_text
      FROM mvw_domestic_rr_search rr
    SQL

    ActiveRecord::Base.connection.exec_query(sql, "SQL").map { |result| result }
  end
end
