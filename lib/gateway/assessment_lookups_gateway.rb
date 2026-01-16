module Gateway
  class AssessmentLookupsGateway
    class AssessmentLookups < ActiveRecord::Base
    end

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

    def truncate_tables
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_lookups CASCADE;")

      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_attribute_lookups")
    end

    def get_lookups_by_attribute_and_key(attribute_id:, lookup_key:)
      sql = <<-SQL
        SELECT *, aa.attribute_name
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
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
          attribute_name: result["attribute_name"],
        )
      end
      assessment_lookups
    end

    def fetch_lookups
      sql = <<-SQL
        SELECT DISTINCT attribute_name as lookup_name FROM
                assessment_attributes a
        JOIN assessment_attribute_lookups aal ON a.attribute_id = aal.attribute_id
        ORDER BY attribute_name#{'    '}
      SQL
      ActiveRecord::Base.connection.exec_query(sql).map { |row| row["lookup_name"] }
    end

    def fetch_lookups_values(name:, lookup_key: nil, schema_version: nil)
      sql = <<-SQL
      SELECT lookup_key as key , lookup_value as value, schema_version
      FROM assessment_attribute_lookups aal
      INNER JOIN assessment_lookups al on aal.lookup_id = al.id
      JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
     WHERE  attribute_name = $1
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "name",
          name,
          ActiveRecord::Type::String.new,
        ),
      ]
      index = 2

      if lookup_key
        bindings << ActiveRecord::Relation::QueryAttribute.new(
          "lookup_key",
          lookup_key,
          ActiveRecord::Type::String.new,
        )
        sql << " AND lookup_key = $#{index}"
        index += 1
      end

      if schema_version
        bindings << ActiveRecord::Relation::QueryAttribute.new(
          "schema_version",
          schema_version,
          ActiveRecord::Type::String.new,
        )
        sql << " AND schema_version = $#{index}"
      end

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |row| row }
    end

    def fetch_look_up_csv_data
      sql = <<-SQL
        SELECT aa.attribute_name as code,  al.lookup_key as key, al.lookup_value as value, schema_version
        FROM assessment_lookups al
        JOIN assessment_attribute_lookups aal on aal.lookup_id = al.id
        JOIN public.assessment_attributes aa on aal.attribute_id = aa.attribute_id
      SQL
      ActiveRecord::Base.connection.exec_query(sql).to_a
    end

    def valid_schema_version?(schema_version)
      is_valid = false
      version_number = schema_version.scan(/\d+/).first.to_i
      return false if schema_version.include?("-NI-")

      if schema_version.include?("SAP")
        is_valid = true if version_number > 15
      elsif schema_version.include?("CEPC")
        is_valid = true if version_number > 6
      end
      is_valid
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
