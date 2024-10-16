namespace :one_off do
  task :update_created_at_eav do
    sql = <<~SQL
      INSERT INTO assessment_attribute_values(assessment_id, attribute_id, attribute_value)
      SELECT DISTINCT assessment_id, (SELECT attribute_id FROM assessment_attributes WHERE attribute_name = 'created_at')::bigint, created_at
      FROM assessment_id_created_at r
      ON CONFLICT(attribute_id, assessment_id)
      DO UPDATE SET attribute_value= EXCLUDED.attribute_value;
    SQL

    ActiveRecord::Base.connection.exec_query(sql, "SQL")
  end

  task :update_created_at_doc_store do
    sql = <<~SQL
      UPDATE  assessment_documents ad
      SET  document=jsonb_set(document, '{created_at}', to_jsonb(to_char(r.created_at, 'YYYY-MM-DD HH24:MI:SS.US')))
      FROM assessment_id_created_at r
      WHERE r.assessment_id = ad.assessment_id;
    SQL

    ActiveRecord::Base.connection.exec_query(sql, "SQL")
  end
end
