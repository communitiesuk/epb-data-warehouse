namespace :one_off do
  desc "Apply addition of hashed_assessment_id by updating the document store and EAV table with a new data node or row"
  task :add_hashed_assessment_id_node do
    sql = <<-SQL
       select assessment_id
       FROM assessment_documents
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
