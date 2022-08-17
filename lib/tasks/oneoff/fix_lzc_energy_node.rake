namespace :one_off do
  desc "Apply fix for LZC-Energy-Source by updated the document store and EAV table with an array of values"
  task :fix_lzc_energy_node do
    sql = <<-SQL
       select assessment_id,
       document ->> 'lzc_energy_sources' as lsz_node
       FROM assessment_documents
       WHERE document ->> 'assessment_type' IN ('SAP', 'RdSAP')
       AND nullif((document ->> 'lzc_energy_sources')::json ->> 'lzc_energy_source', '') != ''
    SQL

    results = ActiveRecord::Base.connection.exec_query(sql, "SQL")
    attribute_id = get_attribute_id
    ActiveRecord::Base.transaction do
      results.each do |row|
        node_array = []
        node_array << JSON.parse(row["lsz_node"])["lzc_energy_source"]
        update_json(row["assessment_id"], node_array)
        update_eav(row["assessment_id"], node_array, attribute_id)
      end
    end
  end
end

def update_json(assessment_id, node_array)
  sql = <<-SQL
      UPDATE assessment_documents
      SET document = JSONB_SET(document, '{lzc_energy_sources}', '"#{node_array}"')
      WHERE assessment_id = $1
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

def update_eav(assessment_id, node_array, attribute_id)
  sql = <<-SQL
      UPDATE assessment_attribute_values
      SET json = '#{node_array.to_json}'
      WHERE assessment_id = $1 and attribute_id = $2
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
  ]

  ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
end

def get_attribute_id
  sql = <<-SQL
     SELECT attribute_id FROM assessment_attributes
     WHERE attribute_name = 'lzc_energy_sources'
  SQL
  ActiveRecord::Base.connection.exec_query(sql, "SQL")[0]["attribute_id"].to_i
end
