shared_context "when fetching recommendations report" do
  def get_bindings(**args)
    arr = []

    unless args[:eff_rating].nil?
      args[:eff_rating].each_with_index do |rating, idx|
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
        args[:date_start],
        ActiveRecord::Type::Date.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "date_end",
        args[:date_end],
        ActiveRecord::Type::Date.new,
      ),
    ]

    unless args[:council].nil?
      args[:council].each_with_index do |council, idx|
        arr << ActiveRecord::Relation::QueryAttribute.new(
          "council_#{idx + 1}",
          council,
          ActiveRecord::Type::String.new,
        )
      end
    end

    unless args[:constituency].nil?
      args[:constituency].each_with_index do |constituency, idx|
        arr << ActiveRecord::Relation::QueryAttribute.new(
          "constituency_#{idx + 1}",
          constituency,
          ActiveRecord::Type::String.new,
        )
      end
    end

    unless args[:postcode].nil?
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "postcode",
        args[:postcode],
        ActiveRecord::Type::String.new,
      )
    end

    unless args[:row_limit].nil?
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "limit",
        args[:row_limit],
        ActiveRecord::Type::Integer.new,
      )

    end
    arr
  end

  def search_filter(**args)
    sql = args[:sql]

    index = 1

    unless args[:eff_rating].nil?
      sql << " JOIN ( VALUES "
      sql << args[:eff_rating].each_with_index.map { |_, idx| "($#{index + idx})" }.join(", ")
      sql << ") vals (v) "
      sql << "ON (current_energy_rating = v)"
      index += args[:eff_rating].size
    end

    sql << (sql.include?("WHERE") ? " AND " : " WHERE ")
    sql << "lodgement_date BETWEEN $#{index} AND $#{index + 1}"
    index += 2

    unless args[:council].nil?
      sql << " AND local_authority_label IN ("
      sql << args[:council].each_with_index.map { |_, idx| "$#{index + idx}" }.join(", ")
      sql << ")"
      index += args[:council].size
    end

    unless args[:constituency].nil?
      sql << " AND constituency_label IN ("
      sql << args[:constituency].each_with_index.map { |_, idx| "$#{index + idx}" }.join(", ")
      sql << ")"
      index += args[:constituency].size
    end

    unless args[:postcode].nil?
      sql << " AND postcode = $#{index}"
      index += 1
    end

    unless args[:row_limit].nil?
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
