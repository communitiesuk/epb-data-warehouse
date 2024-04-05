module Gateway
  class ExportHeatPumpsGateway
    def fetch_by_property_type(start_date:, end_date:)
      bindings = [
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
      ]

      sql = <<-SQL
       SELECT
           al.lookup_value as property_type,
           count(assessment_id)
        FROM assessment_documents ad
        JOIN assessment_lookups al ON al.lookup_key = ad.document ->> 'property_type'
        JOIN (
            select distinct lookup_id from assessment_attribute_lookups aal
            join assessment_attributes aa on aal.attribute_id = aa.attribute_id
            where aa.attribute_name = 'property_type' and type_of_assessment = 'SAP'
        ) as aal on aal.lookup_id = al.id
        WHERE ((ad.document -> 'main_heating')::varchar ILIKE '%heat pump%' or (ad.document -> 'main_heating')::varchar ILIKE '%pwmp gwres%')
        AND ad.document->>'registration_date' BETWEEN $1 AND $2
        AND ad.document ->> 'assessment_type' = 'SAP'
        AND ad.document ->> 'postcode' NOT LIKE 'BT%'
        AND ad.document ->> 'transaction_type' = '6'
        GROUP BY al.lookup_value;
      SQL

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |result| result }
    end

    def fetch_by_floor_area(start_date:, end_date:)
      bindings = [
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
      ]

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
            count(assessment_id)
       FROM assessment_documents ad
        WHERE ((ad.document -> 'main_heating')::varchar ILIKE '%heat pump%' or (ad.document -> 'main_heating')::varchar ILIKE '%pwmp gwres%')
        AND ad.document->>'registration_date' BETWEEN $1 AND $2
        AND ad.document ->> 'assessment_type' = 'SAP'
        AND ad.document ->> 'postcode' NOT LIKE 'BT%'
        AND ad.document ->> 'transaction_type' = '6'
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

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |result| result }
    end
  end
end
