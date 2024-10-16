class AddIndexCreatedAtAssessmentDocuments < ActiveRecord::Migration[7.0]
  def self.up
    add_index :assessment_documents, "(document->>'created_At')", using: :btree, name: "index_document_created_At"

  end
  def self.down
    execute "DROP INDEX IF EXISTS index_document_created_At"
  end
end
