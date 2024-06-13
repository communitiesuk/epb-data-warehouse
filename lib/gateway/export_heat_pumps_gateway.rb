module Gateway
  class ExportHeatPumpsGateway
    ASSESSMENT_TYPE = "SAP".freeze
    TRANSACTION_TYPE = "6".freeze
    NOT_POST_CODE = "BT%".freeze
    MAIN_HEATING = "%heat pump%".freeze
    MAIN_HEATING_WELSH = "%pwmp gwres%".freeze
    ENGLAND_AND_WALES_CODES = %w[ENG EAW WLS].freeze

    def fetch_by_property_type(start_date:, end_date:)
      sql = <<-SQL
       SELECT
           al.lookup_value AS property_type,
           COUNT(ad.assessment_id) AS number_of_assessments
       FROM assessment_documents ad
        JOIN assessment_lookups al ON al.lookup_key = ad.document ->> 'property_type'
        JOIN assessments_country_ids ac ON ad.assessment_id= ac.assessment_id
        JOIN countries co ON co.country_id = ac.country_id#{'  '}
         JOIN (
            SELECT DISTINCT lookup_id FROM assessment_attribute_lookups aal
            JOIN assessment_attributes aa ON aal.attribute_id = aa.attribute_id
            WHERE aa.attribute_name = 'property_type' AND type_of_assessment = 'SAP'
         ) AS aal ON aal.lookup_id = al.id
       WHERE  ad.document->>'registration_date' BETWEEN $1 AND $2
         AND ad.document ->> 'assessment_type' = $3
         AND ad.document ->> 'transaction_type' = $4
         AND ((ad.document -> 'main_heating')::varchar ILIKE $5 OR (ad.document -> 'main_heating')::varchar ILIKE $6)
          AND co.country_code IN  (#{england_and_wales_codes})
       GROUP BY al.lookup_value;
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings(start_date:, end_date:)).map { |result| result }
    end

    def fetch_by_floor_area(start_date:, end_date:)
      sql = <<-SQL
       SELECT
         CASE
           WHEN (ad.document ->> 'total_floor_area')::numeric BETWEEN 0 AND 50 THEN 'BETWEEN 0 AND 50'
           WHEN (ad.document ->> 'total_floor_area')::numeric  BETWEEN 51 AND 100 THEN 'BETWEEN 51 AND 100'
           WHEN (ad.document ->> 'total_floor_area')::numeric BETWEEN 101 AND 150 THEN 'BETWEEN 101 AND 150'
           WHEN (ad.document ->> 'total_floor_area')::numeric BETWEEN 151 AND 200 THEN 'BETWEEN 151 AND 200'
           WHEN (ad.document ->> 'total_floor_area')::numeric BETWEEN 201 AND 250 THEN 'BETWEEN 201 AND 250'
           WHEN (ad.document ->> 'total_floor_area')::numeric >= 251 THEN 'GREATER THAN 251'
         END AS total_floor_area,
             COUNT(ad.assessment_id) AS number_of_assessments
       FROM assessment_documents ad
       JOIN assessments_country_ids ac ON ad.assessment_id= ac.assessment_id
       JOIN countries co ON co.country_id = ac.country_id#{'  '}
       WHERE  ad.document->>'registration_date' BETWEEN $1 AND $2
         AND ad.document ->> 'assessment_type' = $3
         AND ad.document ->> 'transaction_type' = $4
         AND ((ad.document -> 'main_heating')::varchar ILIKE $5 OR (ad.document -> 'main_heating')::varchar ILIKE $6)
         AND co.country_code IN  (#{england_and_wales_codes})
       GROUP BY
         CASE
           WHEN (ad.document ->> 'total_floor_area')::numeric BETWEEN 0 AND 50 THEN 'BETWEEN 0 AND 50'
           WHEN (ad.document ->> 'total_floor_area')::numeric  BETWEEN 51 AND 100 THEN 'BETWEEN 51 AND 100'
           WHEN (ad.document ->> 'total_floor_area')::numeric BETWEEN 101 AND 150 THEN 'BETWEEN 101 AND 150'
           WHEN (ad.document ->> 'total_floor_area')::numeric BETWEEN 151 AND 200 THEN 'BETWEEN 151 AND 200'
           WHEN (ad.document ->> 'total_floor_area')::numeric BETWEEN 201 AND 250 THEN 'BETWEEN 201 AND 250'
           WHEN (ad.document ->> 'total_floor_area')::numeric >= 251 THEN 'GREATER THAN 251'
         END
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings(start_date:, end_date:)).map { |result| result }
    end

    def fetch_by_local_authority(start_date:, end_date:)
      sql = <<~SQL
        SELECT COUNT(DISTINCT ad.assessment_id) AS number_of_assessments, onsn.name AS local_authority
        FROM assessment_documents ad
          LEFT JOIN ons_postcode_directory ons ON ad.document ->> 'postcode' = ons.postcode
          LEFT JOIN ons_postcode_directory_names onsn ON ons.local_authority_code = onsn.area_code
         JOIN assessments_country_ids ac ON ad.assessment_id= ac.assessment_id
          JOIN countries co ON co.country_id = ac.country_id#{'  '}
        WHERE  ad.document->>'registration_date' BETWEEN $1 AND $2
          AND ad.document ->> 'assessment_type' = $3
          AND ad.document ->> 'transaction_type' = $4
          AND ((ad.document -> 'main_heating')::varchar  ILIKE $5 OR (ad.document -> 'main_heating')::varchar ILIKE $6)
         AND co.country_code IN  (#{england_and_wales_codes})
        GROUP BY onsn.name;
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings(start_date:, end_date:)).map { |result| result }
    end

    def fetch_by_parliamentary_constituency(start_date:, end_date:)
      sql = <<~SQL
        SELECT onsn.name AS westminster_parliamentary_constituency,
               COUNT(DISTINCT ad.assessment_id) AS number_of_assessments
        FROM assessment_documents ad
          LEFT JOIN ons_postcode_directory ons ON ad.document ->> 'postcode' = ons.postcode
          LEFT JOIN ons_postcode_directory_names onsn ON ons.westminster_parliamentary_constituency_code = onsn.area_code
          JOIN assessments_country_ids ac ON ad.assessment_id= ac.assessment_id
          JOIN countries co ON co.country_id = ac.country_id#{'  '}
        WHERE  ad.document->>'registration_date' BETWEEN $1 AND $2
          AND ad.document ->> 'assessment_type' = $3
          AND ad.document ->> 'transaction_type' = $4
          AND ((ad.document -> 'main_heating')::varchar ILIKE $5 OR (ad.document -> 'main_heating')::varchar ILIKE $6)
        AND co.country_code IN  (#{england_and_wales_codes})
        GROUP BY onsn.name;
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings(start_date:, end_date:)).map { |result| result }
    end

    def fetch_by_description(start_date:, end_date:)
      sql = <<~SQL
        SELECT
          COUNT(DISTINCT assessment_id) AS number_of_assessments,
          CASE
            WHEN main_heating_description ILIKE '%Mixed exhaust air source heat pump%' THEN 'Mixed exhaust air source heat pump'
            WHEN main_heating_description ILIKE '%Exhaust air MEV source heat pump%' THEN 'Exhaust air MEV source heat pump'
            WHEN main_heating_description ILIKE '%Ground source heat pump%' THEN 'Ground source heat pump'
            WHEN ((main_heating_description ILIKE '%Pwmp gwres%') AND (main_heating_description ILIKE '%ddaear%'))  THEN 'Ground source heat pump'
            WHEN main_heating_description ILIKE '%Water source%' THEN 'Water source heat pump'
            WHEN main_heating_description ILIKE '%Solar assisted%' THEN 'Solar assisted heat pump'
            WHEN main_heating_description ILIKE '%Electric heat pump%' THEN 'Electric heat pump'
            WHEN main_heating_description ILIKE '%Community%' THEN 'Community heat pump'
            WHEN main_heating_description ILIKE '%Exhaust source%' THEN 'Exhaust source heat pump'
            WHEN main_heating_description  ILIKE '%Air source heat pump%' THEN 'Air source heat pump'
            WHEN ((main_heating_description ILIKE '%Pwmp gwres%') AND (main_heating_description ILIKE '%awyr%'))  THEN 'Air source heat pump'
            ELSE main_heating_description
          END AS heat_pump_description
        FROM (
        SELECT ad.assessment_id,
               (jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar AS main_heating_description
        FROM assessment_documents ad
          JOIN assessments_country_ids ac ON ad.assessment_id= ac.assessment_id
          JOIN countries co ON co.country_id = ac.country_id#{'  '}
        WHERE ad.document->>'registration_date' BETWEEN $1 AND $2
          AND ad.document ->> 'assessment_type' = 'SAP'
          AND co.country_code IN  (#{england_and_wales_codes})#{' '}
          AND ad.document ->> 'transaction_type' = '6') AS main_heating_query
        #{'   '}
        WHERE ((main_heating_description ILIKE '%heat pump%') OR (main_heating_description ILIKE '%pwmp gwres%'))
        GROUP BY
          CASE
            WHEN main_heating_description ILIKE '%Mixed exhaust air source heat pump%' THEN 'Mixed exhaust air source heat pump'
            WHEN main_heating_description ILIKE '%Exhaust air MEV source heat pump%' THEN 'Exhaust air MEV source heat pump'
            WHEN main_heating_description ILIKE '%Ground source heat pump%' THEN 'Ground source heat pump'
            WHEN ((main_heating_description ILIKE '%Pwmp gwres%') AND (main_heating_description ILIKE '%ddaear%'))  THEN 'Ground source heat pump'
            WHEN main_heating_description ILIKE '%Water source%' THEN 'Water source heat pump'
            WHEN main_heating_description ILIKE '%Solar assisted%' THEN 'Solar assisted heat pump'
            WHEN main_heating_description ILIKE '%Electric heat pump%' THEN 'Electric heat pump'
            WHEN main_heating_description ILIKE '%Community%' THEN 'Community heat pump'
            WHEN main_heating_description ILIKE '%Exhaust source%' THEN 'Exhaust source heat pump'
            WHEN main_heating_description  ILIKE '%Air source heat pump%' THEN 'Air source heat pump'
            WHEN ((main_heating_description ILIKE '%Pwmp gwres%') AND (main_heating_description ILIKE '%awyr%'))  THEN 'Air source heat pump'
            ELSE main_heating_description
          END
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings(start_date:, end_date:).first(2)).map { |result| result }
    end

  private

    def bindings(start_date:, end_date:)
      [
        ActiveRecord::Relation::QueryAttribute.new(
          "start_date",
          start_date,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "end_date",
          end_date,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_type",
          ASSESSMENT_TYPE,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "transaction_type",
          TRANSACTION_TYPE,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "main_heating",
          MAIN_HEATING,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "main_heating_welsh",
          MAIN_HEATING_WELSH,
          ActiveRecord::Type::String.new,
        ),
      ]
    end

    def england_and_wales_codes
      ENGLAND_AND_WALES_CODES.map { |n| "'#{n}'" }.join(",")
    end
  end
end
