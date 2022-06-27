class AddInitialDocumentStoreIndexes < ActiveRecord::Migration[7.0]
  ATTRIBUTES = %i[
    postcode
    registration_date
    schema_type
    assessment_type
  ].freeze

  def self.up
    ATTRIBUTES.each do |attribute|
      add_index :assessment_documents, "(document->>'#{attribute}')", using: :btree, name: "index_document_#{attribute}"
    end
  end

  def self.down
    ATTRIBUTES.each do |attribute|
      remove_index :assessment_documents, name: "index_document_#{attribute}"
    end
  end
end
