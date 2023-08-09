namespace :one_off do
  desc "Apply addition of hashed_assessment_id by updating the document store and EAV table with a new data node or row"
  task :add_hashed_assessment_id_node do
    sql = <<-SQL
       select assessment_id
       FROM assessment_documents
    SQL

    attribute_id = get_attribute_id_for_hashed_assessment_id

    raw_connection = ActiveRecord::Base.connection.raw_connection
    raw_connection.send_query(sql)
    raw_connection.set_single_row_mode

    raw_connection.get_result.stream_each.map { |row| row["assessment_id"] }.each_slice(500) do |assessment_ids|
      assessment_ids.each do |assessment_id|
        hashed_assessment_id = Helper::HashedAssessmentId.hash_rrn(assessment_id)
        update_hashed_assessment_id_json(assessment_id, hashed_assessment_id)
        update_hashed_assessment_id_eav(assessment_id, hashed_assessment_id, attribute_id)
      end
    end
  end
end

def update_hashed_assessment_id_json(assessment_id, hashed_assessment_id)
  sql = <<-SQL
      UPDATE assessment_documents
      SET document = JSONB_SET(document, '{hashed_assessment_id}', '"#{hashed_assessment_id}"')
      WHERE assessment_id = $1;
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

def update_hashed_assessment_id_eav(assessment_id, hashed_assessment_id, attribute_id)
  sql = <<-SQL
    INSERT INTO assessment_attribute_values (assessment_id, attribute_id, attribute_value)
    VALUES ($1, $2, $3)
    ON CONFLICT (assessment_id, attribute_id) DO UPDATE
    SET attribute_value = $3,
        attribute_value_int = null,
        attribute_value_float = null;
  SQL

  bindings = [
    ActiveRecord::Relation::QueryAttribute.new(
      "assessment_id",
      assessment_id,
      ActiveRecord::Type::String.new,
    ),
    ActiveRecord::Relation::QueryAttribute.new(
      "attribute_id",
      attribute_id,
      ActiveRecord::Type::Integer.new,
    ),
    ActiveRecord::Relation::QueryAttribute.new(
      "hashed_assessment_id",
      hashed_assessment_id,
      ActiveRecord::Type::String.new,
    ),
  ]

  ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
end

def get_attribute_id_for_hashed_assessment_id
  sql = <<-SQL
     SELECT attribute_id FROM assessment_attributes
     WHERE attribute_name = 'hashed_assessment_id'
  SQL
  ActiveRecord::Base.connection.exec_query(sql, "SQL")[0]["attribute_id"].to_i
end
