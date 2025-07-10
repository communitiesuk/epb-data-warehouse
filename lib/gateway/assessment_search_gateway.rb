class Gateway::AssessmentSearchGateway
  class AssessmentSearch < ActiveRecord::Base
  end

  VALID_COUNTRY_IDS = [1, 2, 4].freeze
  AC_CERTIFICATE_TYPE = "AC-CERT".freeze

  def initialize; end

  def insert_assessment(assessment_id:, document:, country_id:)
    document_clone = document.clone
    document_clone.deep_symbolize_keys!
    return unless VALID_COUNTRY_IDS.include?(country_id)
    return if document_clone[:assessment_type] == AC_CERTIFICATE_TYPE

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
      assessment_address_id,
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
    ON CONFLICT (assessment_id) DO NOTHING;
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
        "assessment_address_id",
        document_clone[:assessment_address_id],
        ActiveRecord::Type::String.new,
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
        Time.now,
        ActiveRecord::Type::DateTime.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
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
end
