module Gateway
  class DocumentsGateway
    class AssessmentDocument < ActiveRecord::Base
    end

    def add_assessment(assessment_id:, document:)
      sql = <<-SQL
        INSERT INTO assessment_documents (assessment_id, document, warehouse_created_at, updated_at) VALUES ($1, $2, $3, $4)
           ON CONFLICT(assessment_id)
        DO UPDATE SET document=$2, updated_at=$3
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "document",
          document,
          ActiveRecord::Type::Json.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "created_at",
          Time.now.utc,
          ActiveRecord::Type::DateTime.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "updated_at",
          Time.now.utc,
          ActiveRecord::Type::DateTime.new,
        ),
      ]
      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
    end

    def fetch_assessments_json(date_from:, date_to:)
      sql = <<-SQL
        SELECT ad.document, ad.assessment_id
        FROM assessment_documents ad
        JOIN assessments_country_ids aci ON ad.assessment_id = aci.assessment_id
        JOIN countries c ON c.country_id = aci.country_id
        WHERE warehouse_created_at between $1 and $2
        AND c.country_code IN ('ENG', 'WAL', 'EAW')
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "date_from",
          date_from,
          ActiveRecord::Type::DateTime.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "date_to",
          date_to,
          ActiveRecord::Type::DateTime.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |result| Domain::RedactedDocument.new(result:).to_hash }
    end

    def set_top_level_attribute(assessment_id:, top_level_attribute:, new_value:)
      sql = <<-SQL
        UPDATE assessment_documents SET document=jsonb_set(document, '{#{top_level_attribute}}', $1::jsonb), updated_at=$2 WHERE assessment_id=$3
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "new_value",
          new_value,
          ActiveRecord::Type::Json.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "updated_at",
          Time.now.utc,
          ActiveRecord::Type::DateTime.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SET_ATTR_SQL", bindings)
    end

    def delete_top_level_attribute(assessment_id:, top_level_attribute:)
      sql = <<-SQL
        UPDATE assessment_documents SET document = document - '#{top_level_attribute}', updated_at=$1 WHERE assessment_id=$2
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "updated_at",
          Time.now.utc,
          ActiveRecord::Type::DateTime.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SET_ATTR_SQL", bindings)
    end

    def delete_assessment(assessment_id:)
      sql = <<-SQL
              DELETE FROM assessment_documents
              WHERE assessment_id=$1
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
    end
  end
end
