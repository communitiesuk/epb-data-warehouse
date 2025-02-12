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
                        SELECT aav.assessment_id as rrn,
           items.sequence as IMPROVEMENT_ITEM,
                        items.improvement_category as IMPROVEMENT_ID,
                        items.indicative_cost as INDICATIVE_COST,
              CASE WHEN  (improvement_details -> 'improvement_texts') IS NULL THEN
             get_lookup_value('improvement_summary', (items.improvement_details ->> 'improvement_number'),  t.assessment_type, s.schema_type )

                 ELSE (improvement_details -> 'improvement_texts' ->> 'improvement_summary')::varchar END
                  as improvement_summary_text,

            CASE WHEN (improvement_details -> 'improvement_texts') IS NULL THEN
            get_lookup_value('improvement_description', (items.improvement_details ->> 'improvement_number'),  t.assessment_type, s.schema_type )::varchar
              ELSE (improvement_details -> 'improvement_texts' ->> 'improvement_description')::varchar END
                      as improvement_descr_text
        FROM assessment_attribute_values aav
        CROSS JOIN LATERAL json_to_recordset(json::json) AS  items(sequence integer, indicative_cost varchar, improvement_type varchar,improvement_category varchar,  improvement_details json  )
        JOIN mvw_domestic_search mvw ON mvw.rrn = aav.assessment_id
        JOIN public.assessment_attributes aa on aa.attribute_id = aav.attribute_id
        JOIN (SELECT aav1.assessment_id, aav1.attribute_value as schema_type
                       FROM assessment_attribute_values aav1
                       JOIN public.assessment_attributes a1 on aav1.attribute_id = a1.attribute_id
                       WHERE a1.attribute_name = 'schema_type')  as s
                      ON s.assessment_id = aav.assessment_id
        JOIN (SELECT aav2.assessment_id, aav2.attribute_value as assessment_type
                       FROM assessment_attribute_values aav2
                       JOIN public.assessment_attributes a2 on aav2.attribute_id = a2.attribute_id
                       WHERE a2.attribute_name = 'assessment_type')  as t
                      ON t.assessment_id = aav.assessment_id
        WHERE aa.attribute_name = 'suggested_improvements'
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
