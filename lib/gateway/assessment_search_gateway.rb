class Gateway::AssessmentSearchGateway
  class AssessmentSearch < ActiveRecord::Base; end

  VALID_COUNTRY_IDS = [1, 2, 3, 4].freeze
  AC_CERTIFICATE_TYPE = "AC-CERT".freeze

  def insert_assessment(assessment_id:, document:, country_id:)
    document_clone = document.clone
    document_clone.deep_symbolize_keys!
    return unless VALID_COUNTRY_IDS.include?(country_id)
    return if document_clone[:assessment_type] == AC_CERTIFICATE_TYPE

    created_at = document_clone[:created_at] || Time.now
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
      created_at,
      schema_type,
      country_id
    )
    SELECT
      $1, $2, $3, $4, $5, $6, $7::varchar,
      COALESCE($8, 0), CASE WHEN COALESCE($8, 0) = 0 THEN NULL ELSE energy_band_calculator($8, $12) END,
      n.name, n1.name,
      $9, $10, $11, $12, $13, $14, $15
    FROM (SELECT $7 AS postcode) p
    LEFT JOIN ons_postcode_directory d ON d.postcode = p.postcode
    LEFT JOIN ons_postcode_directory_names n  ON d.local_authority_code = n.area_code AND  n.type = 'Local authority'
    LEFT JOIN ons_postcode_directory_names n1
      ON d.westminster_parliamentary_constituency_code = n1.area_code AND n1.type = 'Westminster parliamentary constituency'
    LIMIT 1
    ON CONFLICT (assessment_id, registration_date)
    DO UPDATE SET
      address_line_1 = excluded.address_line_1,
      address_line_2 = excluded.address_line_2,
      address_line_3 = excluded.address_line_3,
      address_line_4 = excluded.address_line_4,
      post_town = excluded.post_town,
      address = excluded.address;
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
      ActiveRecord::Relation::QueryAttribute.new(
        "schema_type",
        document_clone[:schema_type],
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "country_id",
        country_id,
        ActiveRecord::Type::BigInteger.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
  end

  def update_uprn(assessment_id:, new_value:, override: true)
    conditions = ["assessment_id = $2"]
    conditions << "uprn IS NULL" unless override

    sql = <<-SQL
    UPDATE assessment_search
    SET uprn = $1
    WHERE #{conditions.join(' AND ')}
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

  def fetch_assessments(**args)
    select_fields = <<-SQL
      s.assessment_id AS certificate_number,
      s.address_line_1,
      s.address_line_2,
      s.address_line_3,
      s.address_line_4,
      s.postcode,
      s.post_town,
      s.council,
      s.constituency,
      s.current_energy_efficiency_band,
      to_char(s.registration_date, 'YYYY-MM-DD') as  registration_date,
      s.uprn,
      s.schema_type
    SQL

    is_cepc = args[:assessment_type].include?("CEPC")

    select_fields << ", cr.related_rrn" if is_cepc

    sql = <<-SQL
      SELECT
        #{select_fields}
      FROM assessment_search s
    SQL

    sql << " JOIN commercial_reports cr ON s.assessment_id = cr.assessment_id" if is_cepc

    bindings = get_bindings(**args)
    sql << search_filter(**args)
    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |row| row }
  end

  def count(**args)
    sql = <<~SQL
      SELECT COUNT(*)
      FROM assessment_search s
    SQL

    bindings = get_bindings(**args)
    sql << search_filter(**args)

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
    full_address = arr.map(&:to_s).reject(&:empty?).join(" ")
    Helper::SearchParams.format_address(full_address)
  end

  def get_bindings(**args)
    arr = []

    args[:assessment_type].each_with_index do |type, idx|
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "assessment_type#{idx + 1}",
        type,
        ActiveRecord::Type::String.new,
      )
    end

    unless args[:eff_rating].nil?
      args[:eff_rating].each_with_index do |rating, idx|
        arr << ActiveRecord::Relation::QueryAttribute.new(
          "eff_rating_#{idx + 1}",
          rating,
          ActiveRecord::Type::String.new,
        )
      end
    end

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

    unless args[:date_start].nil? || args[:date_end].nil?
      arr.concat [
        ActiveRecord::Relation::QueryAttribute.new(
          "date_start",
          args[:date_start],
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "date_end",
          "#{args[:date_end]} 12:00:00",
          ActiveRecord::Type::String.new,
        ),
      ]
    end

    unless args[:address].nil?
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "address",
        "%#{args[:address]}%",
        ActiveRecord::Type::String.new,
      )
    end

    unless args[:postcode].nil?
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "postcode",
        format_postcode(args[:postcode]),
        ActiveRecord::Type::String.new,
      )
    end

    unless args[:uprn].nil?
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "uprn",
        args[:uprn],
        ActiveRecord::Type::BigInteger.new,
      )
    end

    if args[:row_limit]
      arr << ActiveRecord::Relation::QueryAttribute.new(
        "limit",
        args[:row_limit],
        ActiveRecord::Type::Integer.new,
      )
      unless args[:current_page].nil?
        arr << ActiveRecord::Relation::QueryAttribute.new(
          "offset",
          calculate_offset(args[:current_page], args[:row_limit]),
          ActiveRecord::Type::Integer.new,
        )
      end
    end

    arr
  end

  def search_filter(**args)
    sql = ""

    unless Helper::Toggles.enabled?("data_warehouse_enable_NI_data")
      sql << " JOIN countries co ON s.country_id = co.country_id"
    end

    index = 1

    sql << " JOIN ( VALUES "
    sql << args[:assessment_type].each_with_index.map { |_, idx| "($#{index + idx})" }.join(", ")
    sql << ") types (t) "
    sql << "ON (assessment_type = t)"
    index += args[:assessment_type].size

    unless args[:eff_rating].nil?
      sql << " JOIN ( VALUES "
      sql << args[:eff_rating].each_with_index.map { |_, idx| "($#{index + idx})" }.join(", ")
      sql << ") ratings (r) "
      sql << "ON (current_energy_efficiency_band = r)"
      index += args[:eff_rating].size
    end

    unless args[:council].nil?
      sql << " JOIN ( VALUES "
      sql << args[:council].each_with_index.map { |_, idx| "($#{index + idx})" }.join(", ")
      sql << ") councils (c) "
      sql << "ON (council = c)"
      index += args[:council].size
    end

    unless args[:constituency].nil?
      sql << " JOIN ( VALUES "
      sql << args[:constituency].each_with_index.map { |_, idx| "($#{index + idx})" }.join(", ")
      sql << ") cons (d) "
      sql << "ON (constituency = d)"
      index += args[:constituency].size
    end

    sql << " WHERE 0 = 0"

    unless args[:date_start].nil? || args[:date_end].nil?
      sql << " AND registration_date BETWEEN $#{index} AND $#{index + 1}"
      index += 2
    end

    unless args[:address].nil?
      sql << " AND address LIKE $#{index}"
      index += 1
    end

    unless args[:postcode].nil?
      sql << " AND postcode = $#{index}"
      index += 1
    end

    unless args[:uprn].nil?
      sql << " AND uprn = $#{index}"
      index += 1
    end

    sql << " AND NOT created_at::date = CURRENT_DATE"

    unless Helper::Toggles.enabled?("data_warehouse_enable_NI_data")
      sql << " AND co.country_code IN ('EAW', 'ENG', 'WLS')"
    end

    if args[:row_limit]
      sql << " ORDER BY registration_date DESC"
      sql << " LIMIT $#{index}"
      sql << " OFFSET $#{index + 1}" unless args[:current_page].nil?
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
