class Gateway::AssessmentSearchGateway
  class AssessmentSearch < ActiveRecord::Base
  end

  VALID_COUNTRY_IDS = [1, 2, 4].freeze
  AC_CERTIFICATE_TYPE = "AC-CERT".freeze

  def initialize; end

  def insert_assessment(assessment_id:, document:, country_id:, created_at: nil)
    document_clone = document.clone
    document_clone.deep_symbolize_keys!
    return unless VALID_COUNTRY_IDS.include?(country_id)
    return if document_clone[:assessment_type] == AC_CERTIFICATE_TYPE

    created_at ||= Time.now
    sql = <<-SQL
    INSERT INTO assessment_search (
      assessment_id,
      address_line_1,
      address_line_2,
      address_line_3,
      address_line_4,
      post_town,
      postcode,
      current_energy_efficiency_rating,
      current_energy_efficiency_band,
      council,
      constituency,
      uprn,
      address,
      registration_date,
      assessment_type,
      created_at
    )
    SELECT
      $1, $2, $3, $4, $5, $6, $7::varchar,
      COALESCE($8, 0), CASE WHEN COALESCE($8, 0) = 0 THEN NULL ELSE energy_band_calculator($8, $12) END,
      n.name, n1.name,
      $9, $10, $11, $12, $13
    FROM (SELECT $7 AS postcode) p
    LEFT JOIN ons_postcode_directory d ON d.postcode = p.postcode
    LEFT JOIN ons_postcode_directory_names n  ON d.local_authority_code = n.area_code AND  n.type = 'Local authority'
    LEFT JOIN ons_postcode_directory_names n1
      ON d.westminster_parliamentary_constituency_code = n1.area_code AND n1.type = 'Westminster parliamentary constituency'
    LIMIT 1
    ON CONFLICT (assessment_id, registration_date) DO NOTHING;
    SQL

    address = generate_address(document: document_clone)

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "address_line_1",
        document_clone[:address_line_1],
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "address_line_2",
        document_clone[:address_line_2],
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "address_line_3",
        document_clone[:address_line_3],
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "address_line_4",
        document_clone[:address_line_4],
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "post_town",
        document_clone[:post_town],
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "postcode",
        document_clone[:postcode],
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "current_energy_efficiency_rating",
        get_energy_rating(document: document_clone),
        ActiveRecord::Type::Integer.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "uprn",
        get_uprn(document_clone[:assessment_address_id]),
        ActiveRecord::Type::BigInteger.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "address",
        address,
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "registration_date",
        document_clone[:registration_date],
        ActiveRecord::Type::DateTime.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_type",
        document_clone[:assessment_type],
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "created_at",
        created_at,
        ActiveRecord::Type::DateTime.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
  end

  def update_uprn(assessment_id:, new_value:)
    sql = <<-SQL
      UPDATE assessment_search
      SET uprn = $1
      WHERE assessment_id = $2
    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "uprn",
        get_uprn(new_value),
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "UPDATE_ASSESSMENT_SEARCH_ATTR", bindings)
  end

  def delete_assessment(assessment_id:)
    sql = <<-SQL
        DELETE FROM assessment_search  WHERE assessment_id = $1
    SQL
    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
    ]
    ActiveRecord::Base.connection.delete(sql, "SQL", bindings)
  end

  def fetch_assessments(*args)
    this_args = args.first
    sql = <<-SQL
        SELECT assessment_id AS certificate_number,
               address_line_1,
               address_line_2,
               address_line_3,
               address_line_4,
               postcode,
               post_town,
               council,
               constituency,
               current_energy_efficiency_band,
               registration_date,
               uprn
               FROM assessment_search
    SQL

    this_args[:sql] = sql
    this_args[:limit] = true
    bindings = get_bindings(**this_args)
    sql = search_filter(**this_args)

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |row| row }
  end

  def count(*args)
    this_args = args.first
    sql = <<~SQL
      SELECT COUNT(*)
      FROM assessment_search
    SQL

    this_args[:sql] = sql
    bindings = get_bindings(**this_args)
    sql = search_filter(**this_args)

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).first["count"]
  end

  def get_uprn(assessment_address_id)
    return nil if assessment_address_id.nil? || assessment_address_id.include?("RRN-")

    assessment_address_id.gsub("UPRN-", "").to_i
  end

private

  def get_energy_rating(document:)
    case document[:assessment_type]
    when "CEPC"
      document[:asset_rating]
    when "DEC"
      document[:this_assessment][:energy_rating]
    when "DEC-RR"
      0
    else
      document[:energy_rating_current]
    end
  rescue NoMethodError
    0
  end

  def generate_address(document:)
    arr = []
    keys = %i[address_line_1 address_line_2 address_line_3 address_line_4 post_town]
    keys.each do |key|
      arr.append(document[key]) unless document[key].nil?
    end
    arr.map(&:to_s).reject(&:empty?).join(" ").downcase
  end

  def get_bindings(*args)
    this_args = args.first
    arr = []

    this_args[:assessment_type].each_with_index do |type, idx|
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "assessment_type#{idx + 1}",
        type,
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

    unless this_args[:date_start].nil? || this_args[:date_end].nil?
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
    end

    unless this_args[:address].nil?
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "address",
        "%#{this_args[:address].downcase}%",
        ActiveRecord::Type::String.new,
      )
    end

    unless this_args[:postcode].nil?
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "postcode",
        format_postcode(this_args[:postcode]),
        ActiveRecord::Type::String.new,
      )
    end

    unless this_args[:uprn].nil?
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "uprn",
        this_args[:uprn],
        ActiveRecord::Type::BigInteger.new,
      )
    end

    if this_args[:row_limit]
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "limit",
        this_args[:row_limit],
        ActiveRecord::Type::Integer.new,
      )
      unless this_args[:current_page].nil?
        arr << ActiveRecord::Relation::QueryAttribute.new(
          "offset",
          calculate_offset(this_args[:current_page], this_args[:row_limit]),
          ActiveRecord::Type::Integer.new,
        )
      end
    end

    arr
  end

  def search_filter(*args)
    this_args = args.first
    sql = this_args[:sql]

    index = 1

    sql << " JOIN ( VALUES "
    sql << this_args[:assessment_type].each_with_index.map { |_, idx| "($#{index + idx})" }.join(", ")
    sql << ") types (t) "
    sql << "ON (assessment_type = t)"
    index += this_args[:assessment_type].size

    unless this_args[:eff_rating].nil?
      sql << " JOIN ( VALUES "
      sql << this_args[:eff_rating].each_with_index.map { |_, idx| "($#{index + idx})" }.join(", ")
      sql << ") ratings (r) "
      sql << "ON (current_energy_efficiency_band = r)"
      index += this_args[:eff_rating].size
    end

    unless this_args[:council].nil?
      sql << " JOIN ( VALUES "
      sql << this_args[:council].each_with_index.map { |_, idx| "($#{index + idx})" }.join(", ")
      sql << ") councils (c) "
      sql << "ON (council = c)"
      index += this_args[:council].size
    end

    unless this_args[:constituency].nil?
      sql << " JOIN ( VALUES "
      sql << this_args[:constituency].each_with_index.map { |_, idx| "($#{index + idx})" }.join(", ")
      sql << ") cons (d) "
      sql << "ON (constituency = d)"
      index += this_args[:constituency].size
    end

    sql << " WHERE 0 = 0"

    unless this_args[:date_start].nil? || this_args[:date_end].nil?
      sql << " AND registration_date BETWEEN $#{index} AND $#{index + 1}"
      index += 2
    end

    unless this_args[:address].nil?
      sql << " AND address LIKE $#{index}"
      index += 1
    end

    unless this_args[:postcode].nil?
      sql << " AND postcode = $#{index}"
      index += 1
    end

    unless this_args[:uprn].nil?
      sql << " AND uprn = $#{index}"
      index += 1
    end

    sql << " AND NOT created_at::date = CURRENT_DATE"

    if this_args[:limit]
      sql << " ORDER BY registration_date DESC"
      sql << " LIMIT $#{index}"
      sql << " OFFSET $#{index + 1}" unless this_args[:current_page].nil?
    end

    sql
  end

  def format_postcode(postcode)
    postcode.gsub!(/[[:space:]]/, "")
    postcode.insert(-4, " ") unless postcode.length < 3
    postcode.upcase
  end

  def calculate_offset(current_page, row_limit)
    current_page = 1 if current_page <= 0
    (current_page - 1) * row_limit
  end
end
