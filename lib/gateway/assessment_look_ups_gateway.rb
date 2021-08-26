module Gateway
  class AssessmentLookUpsGateway
    def add_lookup(assessment_lookup)
      sql = <<-SQL
        INSERT INTO assessment_look_ups(look_up_name, look_up_value, attribute_id, schema, schema_version)
        VALUES($1, $2, $3, $4, $5)
      SQL
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "look_up_name",
          assessment_lookup.lookup_key,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "look_up_value",
          assessment_lookup.lookup_value,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_id",
          assessment_lookup.attribute_id,
          ActiveRecord::Type::BigInteger.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "schema",
          assessment_lookup.type_of_assessment,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "schema_version",
          assessment_lookup.schema_version,
          ActiveRecord::Type::String.new,
        ),
      ]

      result = ActiveRecord::Base.connection.exec_insert(sql, "SQL", bindings)
      assessment_lookup.id = result.first["id"]
    end

    def get_lookups_by_attribute_and_name(attribute_id:, look_up_name:)
      sql = <<-SQL
        SELECT *
        FROM assessment_look_ups
        WHERE attribute_id = $1
        AND look_up_name = $2
      SQL
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_id",
          attribute_id,
          ActiveRecord::Type::BigInteger.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "look_up_name",
          look_up_name,
          ActiveRecord::Type::String.new,
        ),
      ]

      results = ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)

      assessment_lookups = []
      results.each do |result|
        assessment_lookups << Domain::AssessmentLookup.new(
          id: result["id"],
          lookup_key: result["look_up_name"],
          lookup_value: result["look_up_value"],
          attribute_id: result["attribute_id"],
          type_of_assessment: result["schema"],
          schema_version: result["schema_version"],
        )
      end
      assessment_lookups
    end
  end
end
