# frozen_string_literal: true

module Gateway
  class AssessmentsAddressIdGateway
    def insert_or_update_address_id(assessment_id:, address_id:)
      sql = <<~SQL
        INSERT INTO assessments_address_id (assessment_id, address_id)
        VALUES ($1, $2)
        ON CONFLICT (assessment_id)
        DO UPDATE SET address_id = $2;
      SQL

      binds = [
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "address_id",
          address_id,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", binds)
    end

    def insert_or_update_matched_uprn(assessment_id:, matched_uprn:)
      sql = <<~SQL
        INSERT INTO assessments_address_id (assessment_id, matched_uprn)
        VALUES ($1, $2)
        ON CONFLICT (assessment_id)
        DO UPDATE SET matched_uprn = $2;
      SQL

      binds = [
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "matched_uprn",
          matched_uprn,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", binds)
    end
  end
end
