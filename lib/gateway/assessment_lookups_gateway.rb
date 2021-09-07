module Gateway
  class AssessmentLookupsGateway
    def add_lookup(assessment_lookup)
      ActiveRecord::Base.transaction do
        lookup_id = insert_or_get_lookup(
          assessment_lookup.lookup_key,
          assessment_lookup.lookup_value,
        )
        insert_attribute_lookups(
          lookup_id,
          assessment_lookup.attribute_id,
          assessment_lookup.type_of_assessment,
          assessment_lookup.schema_version,
        )
      end
    end

    def get_lookups_by_attribute_and_key(attribute_id:, lookup_key:)
      sql = <<-SQL
        SELECT *
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        WHERE aal.attribute_id = $1
        AND al.lookup_key = $2
      SQL
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_id",
          attribute_id,
          ActiveRecord::Type::BigInteger.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "lookup_key",
          lookup_key,
          ActiveRecord::Type::String.new,
        ),
      ]

      results = ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)

      assessment_lookups = []
      results.each do |result|
        assessment_lookups << Domain::AssessmentLookup.new(
          id: result["id"],
          lookup_key: result["lookup_key"],
          lookup_value: result["lookup_value"],
          attribute_id: result["attribute_id"],
          type_of_assessment: result["type_of_assessment"],
          schema_version: result["schema_version"],
        )
      end
      assessment_lookups
    end

  private

    def insert_attribute_lookups(lookup_id, attribute_id, type_of_assessment, schema_version)
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "lookup_id",
          lookup_id,
          ActiveRecord::Type::BigInteger.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_id",
          attribute_id,
          ActiveRecord::Type::BigInteger.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "type_of_assessment",
          type_of_assessment,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "schema_version",
          schema_version,
          ActiveRecord::Type::String.new,
        ),
      ]

      lookup_select = <<-SQL
          SELECT id FROM assessment_attribute_lookups
          WHERE lookup_id = $1 AND attribute_id = $2 AND type_of_assessment = $3 AND schema_version = $4
      SQL

      lookup = ActiveRecord::Base.connection.exec_query(lookup_select, "SQL", bindings).first

      if lookup.nil?
        attribute_lookups_insert = <<-SQL
          INSERT INTO assessment_attribute_lookups(lookup_id, attribute_id, type_of_assessment, schema_version)
          VALUES($1, $2, $3, $4)
        SQL
        ActiveRecord::Base.connection.insert(attribute_lookups_insert, nil, nil, nil, nil, bindings)
      else
        lookup["id"]
      end
    end

    def insert_or_get_lookup(lookup_key, lookup_value)
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "lookup_key",
          lookup_key,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "lookup_value",
          lookup_value,
          ActiveRecord::Type::String.new,
        ),
      ]

      lookup_select = <<-SQL
          SELECT id FROM assessment_lookups
          WHERE lookup_key = $1
          AND lookup_value = $2
      SQL
      lookup = ActiveRecord::Base.connection.exec_query(lookup_select, "SQL", bindings).first

      if lookup.nil?
        lookup_insert = <<-SQL
          INSERT INTO assessment_lookups(lookup_key, lookup_value)
          VALUES($1, $2)
        SQL
        ActiveRecord::Base.connection.insert(lookup_insert, nil, nil, nil, nil, bindings)
      else
        lookup["id"]
      end
    end
  end
end
