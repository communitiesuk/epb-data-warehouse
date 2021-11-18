module Gateway
  class DocumentsGateway
    def add_assessment(assessment_id:, document:)
      case record_exists?(assessment_id: assessment_id)
      when false
        sql = <<-SQL
        INSERT INTO assessment_documents (assessment_id, document, created_at, updated_at) VALUES ($1, $2, $3, $4)
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
      when true
        update_sql = <<-SQL
          UPDATE assessment_documents SET document=$1, updated_at=$2 WHERE assessment_id=$3
        SQL

        update_bindings = [
          ActiveRecord::Relation::QueryAttribute.new(
            "document",
            document,
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

        ActiveRecord::Base.connection.exec_query(update_sql, "UPDATE_SQL", update_bindings)
      end
    end

    def set_top_level_attribute(assessment_id:, top_level_attribute:, new_value:)
      sql = <<-SQL
        UPDATE assessment_documents SET document=jsonb_set(document, '{#{top_level_attribute}}', $1::jsonb), updated_at=$2 WHERE assessment_id=$3
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "new_value",
          new_value,
          ActiveRecord::Type::String.new,
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

  private

    def record_exists?(assessment_id:)
      count_sql = <<-SQL
        SELECT COUNT(*) AS cnt FROM assessment_documents WHERE assessment_id=$1
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(count_sql, "COUNT_SQL", bindings).first["cnt"] == 1
    end
  end
end
