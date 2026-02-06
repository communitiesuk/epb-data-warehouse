class AddMatchedUprnToAssessmentDocuments < ActiveRecord::Migration[8.1]
  def self.up
    add_column :assessment_documents, :matched_uprn, :bigint
  end

  def self.down
    remove_column :assessment_documents, :matched_uprn
  end
end
