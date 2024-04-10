module Gateway
  class ExportHeatPumpsGateway
    ASSESSMENT_TYPE = "SAP".freeze
    TRANSACTION_TYPE = "6".freeze
    NOT_POST_CODE = "BT%".freeze
    MAIN_HEATING = "%heat pump%".freeze
    MAIN_HEATING_WELSH = "%pwmp gwres%".freeze

    def fetch_by_property_type(start_date:, end_date:)
      sql = <<-SQL
       SELECT
           al.lookup_value as property_type,
           count(assessment_id) as number_of_assessments
        FROM assessment_documents ad
        JOIN assessment_lookups al ON al.lookup_key = ad.document ->> 'property_type'
        JOIN (
            select distinct lookup_id from assessment_attribute_lookups aal
            join assessment_attributes aa on aal.attribute_id = aa.attribute_id
            where aa.attribute_name = 'property_type' and type_of_assessment = 'SAP'
        ) as aal on aal.lookup_id = al.id
        WHERE  ad.document->>'registration_date' BETWEEN $1 AND $2
        AND ad.document ->> 'assessment_type' = $3
        AND ad.document ->> 'transaction_type' = $4
        AND ad.document ->> 'postcode' NOT LIKE $5
        AND ((ad.document -> 'main_heating')::varchar ILIKE $6 or (ad.document -> 'main_heating')::varchar ILIKE $7)
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
           END as total_floor_area,
            count(assessment_id) as number_of_assessments
       FROM assessment_documents ad
         WHERE  ad.document->>'registration_date' BETWEEN $1 AND $2
        AND ad.document ->> 'assessment_type' = $3
        AND ad.document ->> 'transaction_type' = $4
        AND ad.document ->> 'postcode' NOT LIKE $5
        AND ((ad.document -> 'main_heating')::varchar ILIKE $6 or (ad.document -> 'main_heating')::varchar ILIKE $7)
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
              SELECT COUNT(DISTINCT assessment_id) as number_of_assessments,
              onsn.name as local_authority
                FROM assessment_documents ad
                left join ons_postcode_directory ons on ad.document ->> 'postcode' = ons.postcode
                left join ons_postcode_directory_names onsn on ons.local_authority_code = onsn.area_code
         WHERE  ad.document->>'registration_date' BETWEEN $1 AND $2
        AND ad.document ->> 'assessment_type' = $3
        AND ad.document ->> 'transaction_type' = $4
        AND ad.document ->> 'postcode' NOT LIKE $5
        AND ((ad.document -> 'main_heating')::varchar  ILIKE $6 or (ad.document -> 'main_heating')::varchar ILIKE $7)
        GROUP BY onsn.name;
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings(start_date:, end_date:)).map { |result| result }
    end

    def fetch_by_parliamentary_constituency(start_date:, end_date:)
      sql = <<~SQL
              SELECT onsn.name as westminster_parliamentary_constituency,
                    COUNT(DISTINCT assessment_id) as number_of_assessments
                FROM assessment_documents ad
                left join ons_postcode_directory ons on ad.document ->> 'postcode' = ons.postcode
                left join ons_postcode_directory_names onsn on ons.westminster_parliamentary_constituency_code = onsn.area_code
         WHERE  ad.document->>'registration_date' BETWEEN $1 AND $2
        AND ad.document ->> 'assessment_type' = $3
        AND ad.document ->> 'transaction_type' = $4
        AND ad.document ->> 'postcode' NOT LIKE $5
        AND ((ad.document -> 'main_heating')::varchar ILIKE $6 or (ad.document -> 'main_heating')::varchar ILIKE $7)
        GROUP BY onsn.name;
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings(start_date:, end_date:)).map { |result| result }
    end

    def fetch_by_description(start_date:, end_date:)
      sql = <<~SQL
        SELECT
             count(distinct assessment_id) as number_of_assessments,
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
                END as heat_pump_description
        FROM (
        SELECT assessment_id as assessment_id,
               (jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar as main_heating_description
            FROM assessment_documents ad
            WHERE ad.document->>'registration_date' BETWEEN $1 AND $2
            AND ad.document ->> 'assessment_type' = $3
            AND ad.document ->> 'postcode' NOT LIKE $4
            AND ad.document ->> 'transaction_type' = $5) as main_heating_query
        WHERE ((main_heating_description ILIKE $6) OR (main_heating_description ILIKE $7))
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

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings(start_date:, end_date:)).map { |result| result }
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
          "not_post_code",
          NOT_POST_CODE,
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
  end
end
