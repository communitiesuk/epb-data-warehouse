class CreateAssessmentDocumentsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :assessment_documents, primary_key: :assessment_id, id: :string do |t|
      t.jsonb :document, null: false
      t.timestamps
    end
  end
end
