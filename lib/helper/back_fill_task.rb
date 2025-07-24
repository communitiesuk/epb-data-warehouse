class Helper::BackFillTask
  def self.document(assessment_id)
    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
    ]

    doc = ActiveRecord::Base.connection.exec_query("SELECT document FROM assessment_documents WHERE assessment_id =$1", "SQL", bindings).first["document"]
    JSON.parse(doc)
  end
end
